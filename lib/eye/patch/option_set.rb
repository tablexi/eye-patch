class Eye::Patch::OptionSet < Hash

  def initialize(option_class, options)
    Array(options).each do |option|
      option_data = option_class.name_and_class(option[:name].to_sym)
      self[option_data[:name]] = option[:config].merge(type: option_data[:type])
    end
  end
end
