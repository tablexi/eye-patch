require_relative "../../../test_helper"
require "tempfile"

module Eye
  module Patch
    describe Settings do
      it "evaluates the yaml as ERB" do
        file = Tempfile.new("yaml")
        file.write("sum: <%= 1 + 2 %>")
        file.close
        assert_equal 3, Settings.new(file.path)[:sum]
      end

      it "exposes the config file's path within ERB" do
        file = Tempfile.new("yaml")
        file.write("working_dir: <%= __FILE__ %>/..")
        file.close

        assert_equal File.join(file.path, ".."), Settings.new(file.path)[:working_dir]
      end
    end
  end
end
