require "chronic_duration"

module Eye::Patch

  class ValueParser

    TIME_MATCHER = /\s(?<duration>(?:week|day|hour|minute|second)s?)(?:\s|\Z)/
    SIZE_MATCHER = /\s(?<size>(?:tera|giga|mega|kilo)?bytes?)(?:\s|\Z)/
    MATCHERS = {
      time: TIME_MATCHER,
      size: SIZE_MATCHER,
    }.freeze

    def self.parse(value)
      return value unless value.is_a?(String)

      result = MATCHERS.detect do |match_type, matcher|
        break send(:"parse_#{match_type}", value) if value.match(matcher)
      end

      result || value
    end

    def self.parse_time(value)
      ChronicDuration.parse(value)
    end

    def self.parse_size(value)
      unit = value.match(SIZE_MATCHER)[:size]
      value.gsub(/[^\d.]/, "").to_f.send(unit)
    end

  end

end
