class Eye::Patch::ProcessSet < Hash

  def initialize(group, processes)
    @group = group

    Array(processes).each do |process|
      parse_process(process)
    end
  end

  private

  def parse_process(process)
    config = @group.merge(process[:config])
    self[process[:name]] = config.merge(
      name: process[:name],
      group: @group[:name] )
  end
end
