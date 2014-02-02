class Eye::Patch::Application < Hash

  def initialize(settings)
    super()
    @settings = settings
    self[settings[:name].to_s] = parse
  end

  private

  def parse
    @config = {}

    parse_application
    parse_notifications
    parse_triggers
    parse_processes

    @config
  end

  def root_settings
    @settings[:application] || {}
  end

  def parse_application
    @config.merge!(root_settings)
  end

  def parse_notifications
    @config[:notify] = {}

    Array(@settings[:notifications]).each do |monitor|
      @config[:notify][monitor[:name].to_s] = monitor[:level].to_sym
    end
  end

  def parse_triggers
    @config[:triggers] = {}

    Array(@settings[:triggers]).each do |item|
      trigger_data = Eye::Trigger.name_and_class(item[:name].to_sym)
      @config[:triggers][trigger_data[:name]] = item[:config].merge(type: trigger_data[:type])
    end
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
