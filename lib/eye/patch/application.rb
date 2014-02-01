class Eye::Patch::Application

  def initialize(settings)
    ::Eye.application settings[:name] do

      settings[:application].each { |name, setting| send(name, setting) }

      Array(settings[:notifications]).each do |monitor|
        notify monitor[:name], monitor[:level].to_sym
      end

      Array(settings[:triggers]).each do |item|
        trigger item[:name].to_sym, item[:config]
      end

      Array(settings[:processes]).group_by{ |item| item[:group] }.each do |group_name, items|
        if group_name
          # Parse groups
          group(group_name) do
            items.each do |item|
              process item[:name] do
                item[:config].each { |name, setting| send(name, setting) }
              end
            end
          end
        else
          items.each do |item|
            process item[:name] do
              item[:config].each { |name, setting| send(name, setting) }
            end
          end
        end
      end
    end
  end
end
