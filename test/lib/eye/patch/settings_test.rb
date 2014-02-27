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
    end
  end
end
