module Parser
  refine Array do

    def deep_symbolize_keys!
      map do |val|
        val.is_a?(Array) || val.is_a?(Hash) ? val.deep_symbolize_keys! : val
      end
    end
  end

  refine Hash do

    def deep_symbolize_keys!
      keys.each do |key|
        val = delete(key)
        self[key.to_sym] = val.is_a?(Hash) || val.is_a?(Array) ? val.deep_symbolize_keys! : val
      end
      self
    end
  end
end

using Parser

class Eye::Patch::Settings

  def self.parse(filename)
    YAML.load(File.open(filename)).deep_symbolize_keys!
  end
end
