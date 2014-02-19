namespace :load do

  task :defaults do
    set :eye_config, -> { "config/eye.yml" }
    set :eye_bin, -> { "eye-patch" }
    set :eye_roles, -> { :app }
    set :bundle_bins, fetch(:bundle_bins, []).push(fetch(:eye_bin))
  end
end

namespace :eye do

  desc "Start eye with the desired configuration file"
  task :load_config do
    on roles(fetch(:eye_roles)) do
      within current_path do
        execute fetch(:eye_bin), "l #{fetch(:eye_config)}"
      end
    end
  end

  desc "Stop eye and all of its monitored tasks"
  task :stop do
    on roles(fetch(:eye_roles)) do
      within current_path do
        execute fetch(:eye_bin), "stop all"
        execute fetch(:eye_bin), "q"
      end
    end
  end

  desc "Restart all tasks monitored by eye"
  task restart: :load_config do
    on roles(fetch(:eye_roles)) do
      within current_path do
        execute fetch(:eye_bin), "r all"
      end
    end
  end
end

if fetch(:eye_default_hooks, true)
  after "deploy:publishing", "deploy:restart"

  namespace :deploy do
    task :restart do
      invoke "eye:restart"
    end
  end
end
