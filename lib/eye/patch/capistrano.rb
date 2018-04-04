# frozen_string_literal: true

Capistrano::Configuration.instance.load do
  _cset(:eye_default_hooks) { true }
  _cset(:eye_config) { "config/eye.yml" }
  _cset(:eye_bin) { "bundle exec eye-patch" }
  _cset(:eye_roles) { :app }

  if fetch(:eye_default_hooks)
    after  "deploy:stop",    "eye:stop"
    after  "deploy:start",   "eye:load_config"
    before "deploy:restart", "eye:restart"
  end

  namespace :eye do
    desc "Start eye with the desired configuration file"
    task :load_config, roles: -> { fetch(:eye_roles) } do
      run "cd #{current_path} && #{fetch(:eye_bin)} quit"
      run "cd #{current_path} && #{fetch(:eye_bin)} load #{fetch(:eye_config)}"
    end

    desc "Stop eye and all of its monitored tasks"
    task :stop, roles: -> { fetch(:eye_roles) } do
      run "cd #{current_path} && #{fetch(:eye_bin)} stop all"
      run "cd #{current_path} && #{fetch(:eye_bin)} quit"
    end

    desc "Restart all tasks monitored by eye"
    task :restart, roles: -> { fetch(:eye_roles) } do
      run "cd #{current_path} && #{fetch(:eye_bin)} restart all"
    end
  end

  before "eye:restart", "eye:load_config"
end
