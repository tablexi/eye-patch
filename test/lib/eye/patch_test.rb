require_relative "../../test_helper"

describe Eye::Patch do
  before do
    @fixture = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. fixtures test.yml]))
    @original = YAML.load(File.open(@fixture))
  end

  describe ".parse" do
    before do
      Eye::Config.any_instance.stubs(:validate!)
      @parsed = Eye::Patch.parse(@fixture)

      @settings = @parsed.settings
      @applications = @parsed.applications
      @application = @applications.values.first
    end

    it "returns an Eye::Config" do
      assert @parsed.is_a?(Eye::Config)
    end

    it "gives the application an appropriate name" do
      assert_equal @original["name"], @applications.keys.first
      assert_equal @original["name"], @application[:name]
    end

    it "parses contacts for notification" do
      notification = @original["notifications"].first

      assert_equal notification["config"]["from"], @settings[notification["type"].to_sym][:from]
      assert_equal notification["type"].to_sym, @settings[:contacts][notification["name"]][:type]
      assert_equal notification["level"].to_sym, @application[:notify][notification["name"]]
    end

    it "parses triggers" do
      trigger = @original["triggers"].first
      parsed_trigger = @application[:triggers][trigger["name"].to_sym]

      assert_equal trigger["config"]["times"], parsed_trigger[:times]
      assert_equal ChronicDuration.parse(trigger["config"]["within"]), parsed_trigger[:within]
    end

    it "splits processes into groups" do
      grouped_processes = @original["processes"].select { |process| process["group"] }
      grouped_processes.each do |process|
        assert_equal process["group"], @application[:groups][process["group"]][:processes][process["name"]][:group]
      end

      lone_processes = @original["processes"] - grouped_processes
      lone_processes.each do |process|
        assert_equal "__default__", @application[:groups]["__default__"][:processes][process["name"]][:group]
      end
    end

    it "passes application configurations down to processes" do
      process = @application[:groups]["__default__"][:processes].values.first
      assert_equal @application[:triggers], process[:triggers]
    end
  end
end
