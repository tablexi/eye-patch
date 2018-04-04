# frozen_string_literal: true

require_relative "process_set"

module Eye::Patch

  class GroupSet < Hash

    def initialize(application, processes)
      @application = application

      Array(processes).group_by { |item| item[:group] }.each do |group_name, items|
        name = group_name || "__default__"
        parse_group(name, items)
      end
    end

    private

    def parse_group(name, processes)
      self[name] = @application.merge(
        name: name,
        application: @application[:name],
      )

      self[name][:processes] = ProcessSet.new(self[name], processes)
    end

  end

end
