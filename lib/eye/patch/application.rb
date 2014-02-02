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
      if group_name
        parse_group(group_name, items)
      else
        @config[:processes] = parse_process_list(items)
      end
    end
  end

  def parse_group(name, processes)
    @config[:groups][name.to_s] = {}
    @config[:groups][name.to_s][:processes] = parse_process_list(processes)
  end

  def parse_process_list(processes)
    processes.each_with_object({}) do |process, process_map|
      process_map[process[:name].to_s] = process[:config]
    end
  end
end
