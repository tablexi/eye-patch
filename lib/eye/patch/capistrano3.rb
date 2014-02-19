namespace :load do

  task :defaults do
    set :eye_config, -> { "config/eye.yml" }
    set :eye_bin, -> { "bundle exec eye-patch" }
    set :eye_roles, -> { :app }
  end
end

namespace :eye do

  desc "Start eye with the desired configuration file"
  task :load_config do
    on roles(fetch(:eye_roles)) do
      within current_path do
        execute "#{fetch(:eye_bin)} l #{fetch(:eye_config)}"
      end
    end
  end

  desc "Stop eye and all of its monitored tasks"
  task :stop do
    on roles(fetch(:eye_roles)) do
      within current_path do
        execute "#{fetch(:eye_bin)} stop all && #{fetch(:eye_bin)} q"
      end
    end
  end

  desc "Restart all tasks monitored by eye"
  task :restart do
    on roles(fetch(:eye_roles)) do
      within current_path do
        execute "#{fetch(:eye_bin)} r all"
      end
    end
  end
end

if fetch(:eye_default_hooks, true)
  after  "deploy:stop",    "eye:stop"
  after  "deploy:start",   "eye:load_config"
  before "deploy:restart", "eye:restart"
end

before "eye:restart", "eye:load_config"
