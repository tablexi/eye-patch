require "chronic_duration"

module Eye::Patch

  class Settings

    def initialize(filename)
      @settings = YAML.load(File.open(filename))
    end

    def [](value)
      parsed[value]
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
        # Assume that we should parse any time-like values
        item =~ /\b(hour|second|minute)s?\b/ ? ChronicDuration.parse(item) : item
      else
        item
      end
    end
  end
end
