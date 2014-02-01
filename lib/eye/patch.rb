require "eye/patch/version"
require "eye"
require "eye/notify/ses"
require "eye/patch/settings"
require "eye/patch/config"
require "eye/patch/application"

module Eye::Patch

  def self.from(filename)
    settings = Eye::Patch::Settings.parse(filename)
    config = Eye::Patch::Config.new(settings)
    app = Eye::Patch::Application.new(settings)
  end
end
