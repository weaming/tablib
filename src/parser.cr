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
  alias TabAny = BaseTypes | Array(TabAny) | Hash(String, TabAny)

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

  def parse(vs : Array) : Array(TabAny)
    vs.map { |v| parse(v).as(TabAny) }
  end

  def parse(vs : Hash)
    rv = Hash(String, TabAny).new
    vs.reduce(rv) do |memo, x|
      k, v = x
      memo[k.to_s] = parse(v)
      memo
    end
    rv
  end

  def parse(x : JSON::Any) : TabAny
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

  def parse(x : YAML::Any) : TabAny
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

  def flat_hash(row : TabAny) : Hash(String, BaseTypes)
    new_row = Hash(String, BaseTypes).new
    case row
    # only accept Hash
    when Hash
      row.each do |(k, v)|
        case v
        # only accept BaseTypes as value
        when BaseTypes
          new_row[k] = v
        else
          puts "type of hash value #{v} is not BaseTypes, key is #{k}"
          exit 1
        end
      end
    end

    new_row
  end

  def to_csv(x : Array(TabAny)) : String
    new_x = Array(Hash(String, BaseTypes)).new

    # parse type
    x.each do |row|
      flated = flat_hash(row)
      if flated.size > 0
        new_x.push flated
      end
    end

    # generate header
    header = Array(String).new
    new_x[0].each do |(k, v)|
      header.push k # push key
    end

    result = CSV.build do |csv|
      # write header
      csv.row header

      # write body
      new_x.each do |row|
        row_values = Array(BaseTypes).new

        header.each do |k|
          row_values.push row[k].as(BaseTypes)
        end

        csv.row row_values
      end
    end

    result
  end
end
