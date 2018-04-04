# frozen_string_literal: true

require_relative "../../../test_helper"

describe Eye::Patch::ValueParser do
  it "parses time values" do
    assert_equal 2.weeks, Eye::Patch::ValueParser.parse("2 weeks")
    assert_equal 1.5.hours, Eye::Patch::ValueParser.parse("1.5 hours")
    assert_equal 50.minutes, Eye::Patch::ValueParser.parse("50 minutes")
    assert_equal 3.seconds, Eye::Patch::ValueParser.parse("3 seconds")
  end

  it "parses size values" do
    assert_equal 3.2.gigabytes, Eye::Patch::ValueParser.parse("3.2 gigabytes")
    assert_equal 2.4.megabytes, Eye::Patch::ValueParser.parse("2.4 megabytes")
    assert_equal 1.kilobyte, Eye::Patch::ValueParser.parse("1 kilobyte")
    assert_equal 1.terabyte, Eye::Patch::ValueParser.parse("1 terabyte  ")
  end

  it "uses whitespace as word boundary characters" do
    assert_equal "second-thing", Eye::Patch::ValueParser.parse("second-thing")
    assert_equal "minutes", Eye::Patch::ValueParser.parse("minutes")
  end
end
