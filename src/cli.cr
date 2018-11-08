require "./yaml_json"
require "clim"

class Cli < Clim
  PROGRAM = "tabular"
  VERSION = "0.1.0"
  DESC    = "Convert between CSV, JSON, YAML."

  main_command do
    desc DESC.size > 0 ? "#{PROGRAM} -- #{DESC}" : "#{PROGRAM} CLI tool."
    usage "#{PROGRAM} [options] [arguments] ..."
    version VERSION
    option "-f FILE", "--file=FILE", type: String, desc: "The file", default: "."
    option "-t TYPE", "--type", type: String, desc: "The another type exclude JSON", default: "YAML"
    option "-i", "--indent", type: Int32, default: 2

    run do |opts, args|
      # puts opts.file
      # puts opts.type
      # puts opts.indent
      type = opts.type
      file = opts.file

      if !type || type.size == 0
        puts "missing the target type, choices are [CSV, JSON, YAML]"
        exit 1
      end

      type = type.upcase
      case type
      when "CSV", "YAML"
      else
        puts "invalid type #{type}"
        exit 2
      end

      case type
      when "CSV"
        Tablib.csv_json file
      when "YAML"
        Tablib.yaml_json file
      end
    end
  end
end

Cli.start(ARGV)
