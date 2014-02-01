class Eye::Patch::Config

  def initialize(settings)
    ::Eye.config do
      settings[:config].each { |name, setting| send(name, setting) }

      Array(settings[:notifications]).each do |monitor|
        send monitor[:type], monitor[:config]
        contact monitor[:name], monitor[:type].to_sym, monitor[:contact]
      end
    end
  end
end
