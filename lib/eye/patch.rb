require "eye"
require "eye/patch/overrides"

Eye::Notify::TYPES[:ses] = "SES"
Eye::Notify::TYPES[:aws_sdk] = "AWSSDK"
Eye::Notify::TYPES[:datadog] = "DataDog"

module Eye

  class Notify

    autoload :SES, "eye/notify/ses"
    autoload :AWSSDK, "eye/notify/awssdk"
    autoload :DataDog, "eye/notify/datadog"

  end

end

module Eye::Patch

  require "eye/patch/settings"
  require "eye/patch/config"
  require "eye/patch/application"
  require "eye/patch/version"

  def self.parse(filename)
    settings = Settings.new(filename)

    config = ::Eye::Config.new(
      Config.new(settings),
      Application.new(settings),
    )
    config.validate!

    config.applications.values.each do |application|
      next unless application[:setup_file]
      require File.join(application[:working_dir], application[:setup_file])
    end

    config
  end

end
