Eye::Cli.class_eval do
  private

  def loader_path
    filename = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. bin eye-patch-loader]))
    File.exists?(filename) ? filename : nil
  end
end

Eye::Controller.class_eval do
  private

  def parse_config(filename)
    Eye::Patch.parse(filename)
  end
end

Eye::Control
