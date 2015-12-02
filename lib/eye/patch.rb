require "eye"
require "eye/patch/overrides"

begin
  require "eye/notify/ses"
rescue LoadError
  # Don't worry about loading the ses notifier when `aws/ses` is unavailable
end

begin
  require "eye/notify/aws_sdk"
rescue LoadError
  # Don't worry about loading the aws_sdk notifier when
  # `aws-sdk-core` is unavailable
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
      Application.new(settings))
    config.validate!

    config.applications.values.each do |application|
      next unless application[:setup_file]
      require File.join(application[:working_dir], application[:setup_file])
    end

    config
  end
end
