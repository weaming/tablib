require "json"
require "yaml"
require "csv"

def read_file(path : String) : String
  begin
    return File.read(path)
  rescue e
    puts e
    exit 3
  end
end

enum TargetType
  JSON
  YAML
end

module JSONFormatter
  extend self

  alias BaseTypes = String | Bool | Int32 | Int64 | Float64 | Float32 | Nil
  alias HashType = BaseTypes | Array(HashType) | Hash(String, HashType)

  def parse(v : String)
    v.to_s
  end

  def parse(v : Int64 | Int32)
    v.to_i64
  end

  def parse(v : Float64 | Float32)
    v.to_f64
  end

  def parse(v : Bool)
    v == true
  end

  def parse(v : Nil)
    nil
  end

  def parse(vs : Array) : Array(HashType)
    vs.map { |v| parse(v).as(HashType) }
  end

  def parse(vs : Hash)
    rv = Hash(String, HashType).new
    vs.reduce(rv) do |memo, x|
      k, v = x
      memo[k.to_s] = parse(v)
      memo
    end
    rv
  end

  def parse(x : JSON::Any) : HashType
    {% begin %}
       case
        {% for t in ["h", "a", "s", "i", "i64", "f", "f32"] %}
        when x.as_{{t.id}}?
          v = x.as_{{t.id}}
          parse(v)
        {% end %}
        when x.as_nil == nil?
          v = nil
          nil
      end
      {% end %}
  end

  def parse(x : YAML::Any) : HashType
    {% begin %}
       case
        {% for t in ["h", "a", "s", "i", "i64", "f"] %} # missing f32 in YAML::Any
        when x.as_{{t.id}}?
          v = x.as_{{t.id}}
          parse(v)
        {% end %}
        when x.as_nil == nil?
          v = nil
          nil
      end
      {% end %}
  end

  def parse_csv(x : Array(Array(String))) : Array(Hash(String, BaseTypes))
    header = x[0]
    rv = Array.new(x.size - 1, Hash(String, BaseTypes).new)
    (1...x.size).each do |i|
      row = x[i]
      (0...row.size).each do |j|
        key = header[j]
        value = row[j]
        rv[i - 1][key] = value
      end
    end
    rv
  end
end

struct JSON::Any
  def self.to_csv : String
  end
end

module Tablib
  def self.yaml_json(path : String)
    text = read_file path
    if text.size == 0
      exit 8
    end

    if text.strip.starts_with? /[[{]/ # is json
      begin
        data = JSON.parse text
      rescue e
        puts e
        exit 3
      end

      data = JSONFormatter.parse(data)
      puts data.to_yaml
    else # is yaml
      begin
        data = YAML.parse text
      rescue e
        puts e
        exit 4
      end

      data = JSONFormatter.parse(data)
      puts data.to_pretty_json
    end
  end

  def self.csv_json(path : String)
    text = read_file path
    if text.size == 0
      exit 8
    end

    if text.starts_with? /\[\{/ # is json
      begin
        data = JSON.parse text
      rescue e
        puts e
        exit 3
      end

      # output csv
      # TODO

    else # is csv
      begin
        data = CSV.parse text
      rescue e
        puts e
        exit 4
      end

      data = JSONFormatter.parse_csv data
      puts data.to_pretty_json
    end
  end
end
