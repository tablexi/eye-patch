namespace :load do

  task :defaults do
    set :eye_config, -> { "config/eye.yml" }
    set :eye_bin, -> { "eye-patch" }
    set :eye_roles, -> { :app }
    set :eye_env, -> { {} }

    set :rvm_map_bins, fetch(:rvm_map_bins, []).push(fetch(:eye_bin))
    set :rbenv_map_bins, fetch(:rbenv_map_bins, []).push(fetch(:eye_bin))
    set :bundle_bins, fetch(:bundle_bins, []).push(fetch(:eye_bin))
  end
end

namespace :eye do

  desc "Start eye with the desired configuration file"
  task :load_config do
    on roles(fetch(:eye_roles)) do
      within current_path do
        with fetch(:eye_env) do
          execute fetch(:eye_bin), "quit"
          execute fetch(:eye_bin), "load #{fetch(:eye_config)}"
        end
      end
    end
  end

  desc "Start eye with the desired configuration file"
  task :start, :load_config

  desc "Stop eye and all of its monitored tasks"
  task :stop do
    on roles(fetch(:eye_roles)) do
      within current_path do
        with fetch(:eye_env) do
          execute fetch(:eye_bin), "stop all"
          execute fetch(:eye_bin), "quit"
        end
      end
    end
  end

  desc "Restart all tasks monitored by eye"
  task restart: :load_config do
    on roles(fetch(:eye_roles)) do
      within current_path do
        with fetch(:eye_env) do
          execute fetch(:eye_bin), "restart all"
        end
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
