require "json"
require "yaml"

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

module JsonFormatter
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
end

struct JSON::Any
  def self.to_yaml : String
  end

  def self.to_csv : String
  end
end

module Tablib
  def self.yaml_json(path : String)
    text = read_file path
    if text.strip.starts_with? /[[{]/ # is json
      begin
        data = JSON.parse text
      rescue e
        puts e
        exit 3
      end

      data = JsonFormatter.parse(data)
      puts YAML.dump(data)
    else # is yaml
      begin
        data = YAML.parse text
      rescue e
        puts e
        exit 4
      end

      data = JsonFormatter.parse(data)
      puts typeof(data)
      # puts JSON.dumps(data)
    end
  end

  def self.csv_json(path : String)
    text = read_file path
    if text.starts_with? /\[\{/ # is json
      begin
        data = JSON.parse text
      rescue e
        puts e
        exit 3
      end

      # output csv
      # TODO

    else # is yaml
      begin
        data = YAML.parse text
      rescue e
        puts e
        exit 4
      end

      # output json
      # TODO
    end
  end
end
