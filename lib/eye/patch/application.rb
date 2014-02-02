class Eye::Patch::Application < Hash

  def initialize(settings)
    super()
    self[settings[:name].to_s] = parse(settings)
  end

  private

  def parse(settings)
    @config = {}

    parse_application(settings)
    parse_notifications(settings)
    parse_triggers(settings)
    parse_processes(settings)

    @config
  end

  def parse_application(settings)
    @config.merge!(settings[:application] || {})
  end

  def parse_notifications(settings)
    @config[:notify] = {}

    Array(settings[:notifications]).each do |monitor|
      @config[:notify][monitor[:name].to_s] = monitor[:level].to_sym
    end
  end

  def parse_triggers(settings)
    @config[:triggers] = {}

    Array(settings[:triggers]).each do |item|
      trigger_data = Eye::Trigger.name_and_class(item[:name].to_sym)
      @config[:triggers][trigger_data[:name]] = item[:config].merge(type: trigger_data[:type])
    end
  end

  def parse_processes(settings)
    @config[:groups] = {}

    Array(settings[:processes]).group_by{ |item| item[:group] }.each do |group_name, items|
      name = group_name || "__default__"

      @config[:groups][name.to_s] = { application: settings[:name].to_s }
      parse_group(name.to_s, items)
    end
  end

  def parse_group(name, processes)
    @config[:groups][name][:processes] = parse_process_list(name, processes)
  end

  def parse_process_list(group_name, processes)
    processes.each_with_object({}) do |process, process_map|
      process_map[process[:name].to_s] = process[:config].merge(group: group_name)
    end
  end
end
