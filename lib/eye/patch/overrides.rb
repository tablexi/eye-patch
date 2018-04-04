# frozen_string_literal: true

Eye::Cli.class_eval do
  private

  def loader_path
    filename = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. bin eye-patch-loader]))
    File.exist?(filename) ? filename : nil
  end
end

require "eye/utils/mini_active_support"
Eye::Process.class_eval do
  def daemonize_process
    res = Eye::System.daemonize(self[:start_command], config)

    info "daemonizing: `#{self[:start_command]}` with start_grace: #{self[:start_grace].to_f}s, env: #{self[:environment].inspect}, working_dir: #{self[:working_dir]}, <#{res[:pid]}>"

    if res[:error]
      if res[:error].message == "Permission denied - open"
        error "daemonize failed with #{res[:error].inspect}; make sure #{[self[:stdout], self[:stderr]]} are writable"
      else
        error "daemonize failed with #{res[:error].inspect}"
      end

      return { error: res[:error].inspect }
    end

    self.pid = res[:pid]

    unless pid
      error "no pid was returned"
      return { error: :empty_pid }
    end

    sleep_grace(:start_grace)

    unless process_really_running?
      error "process <#{pid}> not found, it may have crashed (#{check_logs_str})"
      return { error: :not_really_running }
    end

    if !self[:smart_pid] && !failsafe_save_pid
      error "expected to manage pidfile for process <#{pid}>; pidfile is unwritable"
      return { error: :cant_write_pid }
    end

    res
  end

  def control_pid?
    !!self[:daemonize] && !self[:smart_pid] # rubocop:disable Style/DoubleNegation
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
        chdir: config[:working_dir] || "/",
        close_others: !config[:preserve_fds],
      }

      options[:out]   = [config[:stdout], "a"] if config[:stdout]
      options[:err]   = [config[:stderr], "a"] if config[:stderr]
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
    return unless respond_to?(:before_spawn)

    debug "Invoking before_spawn hook"
    before_spawn
  end

  private

  def parse_config(filename)
    Eye::Patch.parse(filename)
  end
end

Eye::Control
