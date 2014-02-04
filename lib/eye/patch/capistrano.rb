Capistrano::Configuration.instance.load do

  _cset(:eye_default_hooks) { true }
  _cset(:eye_config) { "config/eye.yml" }
  _cset(:eye_bin) { "bundle exec eye-patch" }
  _cset(:eye_roles) { :app }

  if fetch(:eye_default_hooks)
    after "deploy:stop",     "eye:stop"
    after "deploy:start",    "eye:start"
    before "deploy:restart", "eye:restart"
  end

  namespace :eye do

    desc "Start eye with the desired configuration file"
    task :start, roles: -> { fetch(:eye_roles) } do
      run "cd #{current_path} && #{fetch(:eye_bin)} l #{fetch(:eye_config)}"
    end

    desc "Stop eye and all of its monitored tasks"
    task :stop, roles: -> { fetch(:eye_roles) } do
      run "cd #{current_path} && #{fetch(:eye_bin)} stop all && #{fetch(:eye_bin)} q"
    end

    desc "Restart all tasks monitored by eye"
    task :restart, roles: -> { fetch(:eye_roles) } do
      run "cd #{current_path} && #{fetch(:eye_bin)} r all"
    end
  end
end
