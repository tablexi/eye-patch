require "eye"
require "eye/patch/overrides"

module Eye::Patch

  require "eye/patch/settings"
  require "eye/patch/config"
  require "eye/patch/application"
  require "eye/patch/version"

  def self.parse(filename)
    settings = Eye::Patch::Settings.new(filename)

    config = Eye::Config.new(
      Eye::Patch::Config.new(settings),
      Eye::Patch::Application.new(settings))
    config.validate!

    config
  end
end
