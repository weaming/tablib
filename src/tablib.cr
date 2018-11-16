require "./parser"
require "./cli"

# Parse betwwen YAML, JSON, CSV
module Tablib
  VERSION = "0.1.0"

  def self.yaml_json(path : String)
    text = read_file path
    if text.size == 0
      exit 3
    end

    if text.strip.starts_with? /[[{]/ # is json
      begin
        data = JSON.parse text
      rescue e
        puts e
        exit 4
      end

      data = JSONFormatter.parse(data)
      puts data.to_yaml
    else # is yaml
      begin
        data = YAML.parse text
      rescue e
        puts e
        exit 5
      end

      data = JSONFormatter.parse(data)
      puts data.to_pretty_json
    end
  end

  def self.csv_json(path : String)
    text = read_file path
    if text.size == 0
      exit 3
    end

    if text.starts_with? /[[{]/ # is json
      begin
        data = JSON.parse text
      rescue e
        puts e
        exit 4
      end

      # output csv
      data = JSONFormatter.parse data
      case data
      when Array(JSONFormatter::TabAny)
        str = JSONFormatter.to_csv data
        puts str
      else
        puts "invalid csv 2d structure"
        exit 6
      end
    else # is csv
      begin
        data = CSV.parse text
      rescue e
        puts e
        exit 5
      end

      data = JSONFormatter.parse_csv data
      puts data.to_pretty_json
    end
  end
end
