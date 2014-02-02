class Eye::Patch::Application < Hash

  def initialize(settings)
    super()
    @settings = settings
    self[settings[:name].to_s] = parse
  end

  private

  def parse
    @config = {}

    parse_configuration
    parse_processes

    @config
  end

  def root_settings
    @root_settings ||= (@settings[:application] || {}).merge(
      notify: parse_notifications,
      triggers: parse_triggers,
      checks: parse_checks )
  end

  def parse_notifications
    Array(@settings[:notifications]).each_with_object({}) do |notify, monitors|
      monitors[notify[:name].to_s] = notify[:level].to_sym
    end
  end

  def parse_triggers
    Array(@settings[:triggers]).each_with_object({}) do |trigger, triggers|
      trigger_data = Eye::Trigger.name_and_class(trigger[:name].to_sym)
      triggers[trigger_data[:name]] = trigger[:config].merge(type: trigger_data[:type])
    end
  end

  def parse_checks
    Array(@settings[:checks]).each_with_object({}) do |check, checks|
      check_data = Eye::Checker.name_and_class(check[:name].to_sym)
      checks[check_data[:name]] = check[:config].merge(type: check_data[:type])
    end
  end

  def parse_configuration
    @config.merge!(root_settings)
  end

  def parse_processes
    @config[:groups] = {}

    Array(@settings[:processes]).group_by{ |item| item[:group] }.each do |group_name, items|
      name = group_name || "__default__"
      parse_group(name, items)
    end
  end

  def parse_group(name, processes)
    @config[:groups][name] = root_settings.merge(
      application: @settings[:name].to_s,
      processes: parse_process_list(name, processes))
  end

  def parse_process_list(group_name, processes)
    processes.each_with_object({}) do |process, process_map|
      process_map[process[:name].to_s] = root_settings.merge(process[:config]).merge(
        name: process[:name].to_s,
        group: group_name )
    end
  end
end
