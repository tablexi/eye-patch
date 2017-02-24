require "erb"
require "forwardable"
require_relative "value_parser"

module Eye::Patch

  class Settings
    extend Forwardable
    def_delegators :parsed, :[], :fetch

    def initialize(filename)
      file = File.new(filename)
      erb = ERB.new(file.read)
      erb.filename = file.path

      @settings = YAML.load(erb.result)
    ensure
      file.close unless file.nil?  
    end

    private

    def parsed
      @parsed ||= parse(@settings)
    end

    def parse(item)
      case item
      when Hash
        item.each_with_object({}) do |(key, val), result|
          result[key.to_sym] = parse(val)
        end
      when Array
        item.map { |val| parse(val) }
      when String
        ValueParser.parse(item)
      else
        item
      end
    end
  end
end
