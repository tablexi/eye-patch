Eye::Cli.class_eval do
  private

  def loader_path
    filename = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. bin eye-patch-loader]))
    File.exists?(filename) ? filename : nil
  end
end

Eye::System.class_eval do
  private

  def spawn_options(config = {})
    o = {pgroup: true, chdir: config[:working_dir] || '/'}
    o.update(out: [config[:stdout], 'a']) if config[:stdout]
    o.update(err: [config[:stderr], 'a']) if config[:stderr]
    o.update(in: config[:stdin]) if config[:stdin]
    o.update(close_others: !config[:preserve_fds])

    if Eye::Local.root?
      o.update(uid: Etc.getpwnam(config[:uid]).uid) if config[:uid]
      o.update(gid: Etc.getpwnam(config[:gid]).gid) if config[:gid]
    end

    o.update(umask: config[:umask]) if config[:umask]

    o
  end
end

Eye::Controller.class_eval do
  private

  def parse_config(filename)
    Eye::Patch.parse(filename)
  end
end

Eye::Control
