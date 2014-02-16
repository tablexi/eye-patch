Eye::Cli.class_eval do
  private

  def loader_path
    filename = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. bin eye-patch-loader]))
    File.exists?(filename) ? filename : nil
  end
end

Eye::System.class_eval do
  class << self
    alias_method :daemonize_without_hook, :daemonize
    alias_method :exec_without_hook, :exec

    def daemonize(*args)
      Eye::Control.invoke_spawn_callback
      daemonize_without_hook(*args)
    end

    def exec(*args)
      Eye::Control.invoke_spawn_callback
      exec_without_hook(*args)
    end

    private

    def spawn_options(config = {})
      options = {
        pgroup: true,
        chdir: config[:working_dir] || '/',
        close_others: !config[:preserve_fds] }

      options[:out]   = [config[:stdout], 'a'] if config[:stdout]
      options[:err]   = [config[:stderr], 'a'] if config[:stderr]
      options[:in]    = config[:stdin] if config[:stdin]
      options[:umask] = config[:umask] if config[:umask]

      if Eye::Local.root?
        options[:uid] = Etc.getpwnam(config[:uid]).uid if config[:uid]
        options[:gid] = Etc.getpwnam(config[:gid]).gid if config[:gid]
      end

      options
    end
  end
end

Eye::Controller.class_eval do

  def invoke_spawn_callback
    debug "Attempting before_spawn hook"
    if respond_to?(:before_spawn)
      debug "Invoking before_spawn hook"
      before_spawn
    end
  end

  private

  def parse_config(filename)
    config = Eye::Patch.parse(filename)

    if Eye::Patch.setup_file
      info "Loading setup from: #{Eye::Patch.setup_file}"
      require Eye::Patch.setup_file
    end

    config
  end
end

Eye::Control
