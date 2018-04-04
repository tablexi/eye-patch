# frozen_string_literal: true

require_relative "../../test_helper"

describe Eye::Patch do
  before do
    Eye::Config.any_instance.stubs(:validate!)
  end

  describe ".parse" do
    before do
      @fixture = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. fixtures test.yml]))
      @original = YAML.safe_load(File.open(@fixture))
      @parsed = Eye::Patch.parse(@fixture)

      @settings = @parsed.settings
      @applications = @parsed.applications
      @application = @applications.values.first
    end

    it "returns an Eye::Config" do
      assert_kind_of Eye::Config, @parsed
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

      %w[times within].each do |setting|
        assert_equal Eye::Patch::ValueParser.parse(trigger["config"][setting]), parsed_trigger[setting.to_sym]
      end
    end

    it "parses checks" do
      check = @original["checks"].first
      parsed_check = @application[:checks][check["name"].to_sym]

      %w[times every below].each do |setting|
        assert_equal Eye::Patch::ValueParser.parse(check["config"][setting]), parsed_check[setting.to_sym]
      end
    end

    it "splits processes into groups" do
      grouped_processes = @original["processes"].select { |process| process["group"] && !process["count"] }
      grouped_processes.each do |process|
        assert_equal process["group"], @application[:groups][process["group"]][:processes][process["name"]][:group]
      end
    end

    it "puts ungrouped processes into the __default__ group" do
      lone_processes = @original["processes"].reject { |process| process["group"] }
      lone_processes.each do |process|
        assert_equal "__default__", @application[:groups]["__default__"][:processes][process["name"]][:group]
      end
    end

    it "creates process clusters" do
      process = @original["processes"].detect { |p| p["count"] }
      process["count"].times do |index|
        name = "#{process['name']}-#{index}"
        parsed_process = @application[:groups][process["group"]][:processes][name]

        assert_equal process["group"], parsed_process[:group]
        assert_equal process["config"]["pid_file"].gsub("{ID}", index.to_s), parsed_process[:pid_file]
      end
    end

    it "loads children-level checks" do
      process = @application[:groups]["__default__"][:processes].values.first
      process_config = @original["processes"].detect do |p|
        p["name"] == process[:name]
      end
      check = process_config["config"]["monitor_children"]["checks"].first
      parsed_check = process[:monitor_children][:checks][check["name"].to_sym]

      %w[times every below].each do |setting|
        assert_equal(
          Eye::Patch::ValueParser.parse(check["config"][setting]),
          parsed_check[setting.to_sym],
        )
      end
    end

    it "passes application configurations down to processes" do
      process = @application[:groups]["__default__"][:processes].values.first
      assert_equal @application[:triggers], process[:triggers]
    end

    it "sets :stderr and :stdout options for each process from passed :stdall" do
      process = @original["processes"].reject { |p| p["group"] }.first
      parsed_process = @application[:groups]["__default__"][:processes].values.first

      assert_equal process["config"]["stdall"], parsed_process[:stdout]
      assert_equal process["config"]["stdall"], parsed_process[:stderr]
    end
  end

  describe ".parse with per-process overrides" do
    before do
      @fixture = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. fixtures overrides.yml]))
      @original = YAML.safe_load(File.open(@fixture))
      @parsed = Eye::Patch.parse(@fixture)

      @settings = @parsed.settings
      @applications = @parsed.applications
      @application = @applications.values.first
    end

    it "loads per-process triggers" do
      process = @application[:groups]["__default__"][:processes].values.first
      trigger = @original["processes"].detect { |p| p["name"] == process[:name] }["triggers"].first
      parsed_trigger = process[:triggers][trigger["name"].to_sym]

      %w[times within].each do |setting|
        assert_equal Eye::Patch::ValueParser.parse(trigger["config"][setting]), parsed_trigger[setting.to_sym]
      end
    end

    it "loads per-process checks" do
      process = @application[:groups]["__default__"][:processes].values.first
      check = @original["processes"].detect { |p| p["name"] == process[:name] }["checks"].first
      parsed_check = process[:checks][check["name"].to_sym]

      %w[times every below].each do |setting|
        assert_equal Eye::Patch::ValueParser.parse(check["config"][setting]), parsed_check[setting.to_sym]
      end
    end
  end
end
