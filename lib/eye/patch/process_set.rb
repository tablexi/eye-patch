# frozen_string_literal: true

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
        parse_single_process(
          process[:name],
          process[:config],
          process_monitors(process),
        )
      end
    end

    def parse_process_cluster(process)
      process[:count].times do |index|
        name = "#{process[:name]}-#{index}"
        parse_single_process(
          name,
          indexed_config(process[:config], index),
          process_monitors(process),
        )
      end
    end

    def parse_single_process(name, config, monitors)
      self[name] = @group
        .merge(stdout: config[:stdall], stderr: config[:stdall])
        .merge(config)
        .merge(name: name, group: @group[:name])

      self[name][:triggers] = self[name][:triggers].merge(monitors[:triggers])
      self[name][:checks] = self[name][:checks].merge(monitors[:checks])

      return unless config[:monitor_children]
      return unless config[:monitor_children][:checks]

      monitor_options = OptionSet.new(
        Eye::Checker,
        config[:monitor_children][:checks],
      )

      self[name][:monitor_children][:checks] = monitor_options
    end

    def indexed_config(config, index)
      config.each_with_object({}) do |(key, value), result|
        result[key] = value.is_a?(String) ? value.gsub("{ID}", index.to_s) : value
      end
    end

    def process_monitors(config)
      {
        triggers: OptionSet.new(Eye::Trigger, config[:triggers]),
        checks: OptionSet.new(Eye::Checker, config[:checks]),
      }
    end

  end

end
