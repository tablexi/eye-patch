module Eye::Patch

  class ProcessSet < Hash

    def initialize(group, processes)
      @group = group

      Array(processes).each do |process|
        parse_process(process)
      end
    end

    private

    def parse_process(process)
      if process[:count]
        parse_process_cluster(process)
      else
        parse_single_process(process[:name], process[:config])
      end
    end

    def parse_process_cluster(process)
      process[:count].times do |index|
        name = "#{process[:name]}-#{index}"
        parse_single_process(name, indexed_config(process[:config], index))
      end
    end

    def parse_single_process(name, config)
      self[name] = @group.merge(config).merge(
        name: name,
        group: @group[:name] )
    end

    def indexed_config(config, index)
      config.each_with_object({}) do |(key, value), result|
        result[key] = value.is_a?(String) ? value.gsub(/`ID`/, index.to_s) : value
      end
    end
  end
end
