require_relative "group_set"
require_relative "option_set"

class Eye::Patch::Application < Hash

  def initialize(settings)
    super()
    @settings = settings
    self[settings[:name]] = parse
  end

  private

  def parse
    parse_configuration
    parse_processes

    @config
  end

  def parse_configuration
    @config = (@settings[:application] || {}).merge(
      name: @settings[:name],
      notify: notifications,
      triggers: triggers,
      checks: checks )
  end

  def parse_processes
    @config[:groups] = Eye::Patch::GroupSet.new(@config, @settings[:processes])
  end

  def notifications
    Array(@settings[:notifications]).each_with_object({}) do |notify, monitors|
      monitors[notify[:name]] = notify[:level].to_sym
    end
  end

  def triggers
    Eye::Patch::OptionSet.new(Eye::Trigger, @settings[:triggers])
  end

  def checks
    Eye::Patch::OptionSet.new(Eye::Checker, @settings[:checks])
  end
end
