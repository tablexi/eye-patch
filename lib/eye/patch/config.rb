class Eye::Patch::Config < Hash

  def initialize(settings)
    super()
    merge!(parse(settings))
  end

  private

  def parse(settings)
    return @config if @config
    @config = {}

    parse_config(settings)
    parse_contacts(settings)

    @config
  end

  def parse_config(settings)
    @config.merge!(settings[:config] || {})
  end

  def parse_contacts(settings)
    @config[:contacts] = {}
    Array(settings[:notifications]).each do |notify|
      @config[notify[:type].to_sym] = notify[:config]
      @config[:contacts][notify[:name].to_s] = {
        name: notify[:name].to_s,
        type: notify[:type].to_sym,
        contact: notify[:contact].to_s,
        opts: {},
      }
    end
  end

end
