# Eye::Patch

`Eye::Patch` is a wrapper for the fantastic [`eye`](https://github.com/kostya/eye) process monitoring gem, with support for parsing yaml configuration files and capistrano deploys.

The goal of this gem is to make eye process monitoring easier to set up, manage, and deploy for large applications.

## Installation

Add this line to your application's Gemfile:

    gem "eye-patch"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eye-patch

## Usage

### Configuration

`Eye::Patch` overrides `eye`'s built-in DSL to allow your eye application to be configured in a structured YAML file.

#### Notifications

`Eye::Patch` forgoes granular process-level notification in favor of setting up application-wide notifications for different reporting levels. The following configuration will send all error notifications to the described contact via Amazon's SES service.

Note that SES support will only be provided if a necessary gem is installed on the system.

`Eye::Patch` supports 2 different SES-backed gems:

1. If the [`aws-ses`](https://github.com/drewblas/aws-ses) gem is available on the system, use the `type: ses` setting.

  Example configuration:

      notifications:
        - name: crash # this name must match the "notify" target of the process.
          type: ses # for aws-ses
          level: error
          contact: test+admin@example.com
          config:
            from: eye+notifications@example.com
            access_key_id: Your+AWS+Access+Key+ID
            secret_access_key: Your+AWS+Secret+Access+Key

2. If the [`aws-sdk`](https://github.com/aws/aws-sdk-ruby/) gem is available on the system, use the `type: aws_sdk` setting. (Note: usually this gem is installed as a consequence of installing [aws-sdk-rails](https://github.com/aws/aws-sdk-rails)).

  Example configuration:

      notifications:
        - name: crash # this name must match the "notify" target of the process.
          type: aws_sdk # for aws-sdk
          level: error
          contact: test+admin@example.com
          config:
            from: eye+notifications@example.com
            region: us-east-1 # optional
            # NOTE: the default region is us-east-1. It can be overriden.
            access_key_id: Your+AWS+Access+Key+ID # optional
            secret_access_key: Your+AWS+Secret+Access+Key # optional


In either case above, an example notification block for monitored process:

    processes:
      - name: unicorn
        config:
          pid_file: tmp/pids/unicorn.pid
          start_command: bundle exec unicorn -c config/unicorn/<%= ENV["RAILS_ENV"] %>.rb -D
          ....
          monitor_children:
            stop_command: "kill -QUIT {PID}"
          notify:
            crash: error # this must match the "name" of the notification above

#### Triggers/Checks

Triggers and checks are set up much like `eye`'s basic DSL. All trigger and check types available in `eye` are supported.

    triggers:
      - name: flapping
        config:
          times: 10
          within: 1 minute

    checks:
      - name: memory
        config:
          times: 3
          every: 20 seconds
          below: 1.5 gigabytes

Note that memory and duration values are written in plain english. See `lib/eye/patch/value_parser.rb` for the regular expressions used to parse these values into usable numbers.

#### Processes

`Eye::Patch` uses the same conventions as `eye` for basic process configuration.

    processes:
      - name: my-process
        config:
          start_command: bundle exec my-process
          pid_file: tmp/pids/my-process.pid

Processes will inherit all configurations from the main application. All process options supported by `eye` are available by using the appropriate key in the `config` block.

##### Checks and Triggers

You can define per-process checks and triggers by defining a `checks` or `triggers` block within the process definition.

    processes:
      - name: my-process
        checks:
          - name: memory
            config:
              times: 3
              every: 10 seconds
              below: 52 megabytes
    ...

Any check or trigger already defined at the application level will be overwritten with the new configuration. Application-level checks and triggers which are not redefined for the process will be persisted.

##### Grouping

Rather than using the `eye` DSL's nesting approaching to setting up processes within groups, `Eye::Patch` simply needs a `group` attribute to be added to the process definition.

    processes:
      - name: my-grouped-process
        group: my-group
        config:
    ...

All processes sharing a group name will be grouped together when the configuration is loaded.

##### Copying

On occasion, it's desirable to spin up multiple copies of a process with the same configuration. `Eye::Patch` offers a shorthand for this setup with the `count` attribute.

    processes:
      - name: my-copied-process
        count: 3
        config:
          start_command: bundle exec my-copied-process
          pid_file: "copied-process-{ID}.pid"

The above configuration will spin up a number of processes equal to `count`, resulting in the following monitored processes:

    my-copied-process-0 <copied-process-0.pid>
    my-copied-process-1 <copied-process-1.pid>
    my-copied-process-2 <copied-process-2.pid>

This approach pairs well with the `daemonize: true` option, as `eye` will have control over the creation and management of the enumerated PID files.

### Monkey-Patching

`Eye::Patch` can't cover all possible use cases, so instead, it supplies a few hooks to allow you to inject your own behavior into `eye` during initial load.

#### Defining a Setup File

For the application specified in your configuration file, you can specify a `setup_file` directive, which will tell `Eye::Patch` to load the specified file (relative to the working directory for the application) immediately after parsing your configuration.

This can be used to inject any desired behavior or hooks into `eye`. For example:

`working-dir/config/eye.rb`:

    #!/usr/bin/env/ruby

    Eye::Control.settings[:my_key] = "SOME_KEY"

    Eye::Controller.class_eval do
      def before_spawn
        reader, writer = ::IO.pipe.map(&:binmode)
        reader.close_on_exec = false
        writer.close_on_exec = true

        ENV["MY_FD"] = reader.to_i.to_s

        writer << Eye::Control.settings[:my_key]
        writer.flush
        writer.close
      end
    end

`working-dir/config/eye.yml`:

    ...
    application:
      working_dir: working-dir
      setup_file: config/eye.rb
    ...

#### Using a `before_spawn` Hook

If you need to invoke some code before spawning a process (for example, if you want to make a file descriptor available to your new child process), you can accomplish this by patching `Eye::Controller` with a `#before_spawn` method in your setup file. This method will be invoked prior to `Eye::System` calling `Process.spawn`.

See above for more instructions on how to define this hook during setup.

#### Working with File Descriptors

Note that if you _do_ need to persist file descriptors for a daemonized process, you'll want to set the `preserve_fds: true` option for that particular process in your configuration file. `Process.spawn`'s default behavior closes all non-standard file descriptors; this option will ensure that they remain open.

Note also that since Ruby 2.0, file descriptors are closed when a process is invoked through `bundle exec`. From versions 1.5 and above, you can pass the `--keep-file-descriptors` flag to `bundle exec` to prevent this behavior.

#### Managing Pidfiles

By default, `eye` will attempt to manage the pidfile for any process with the `daemonize: true` flag. In certain cases, this may be undesirable. For example, [`unicorn`](https://github.com/defunkt/unicorn) attempts to manage its own pid, which is necessary for zero-downtime deploys.

To get around this problem, you can supply the `smart_pid: true` option in a process's config hash. This will instruct eye to trust the daemonized process to manage its own pid.

### Running Locally

You can test your configurations locally by running the `eye-patch` binary like so:

    bundle exec eye-patch l config/eye.yml

The `eye-patch` binary wraps the `eye` CLI, with some tweaks to insert `Eye::Patch` as the config file parser.

### Deploying

`Eye::Patch` has built-in support for capistrano deploys. Include the following in your `deploy.rb` file:

    require "eye/patch/capistrano"

For standard capistrano deployments with bundler, this should be enough. If you aren't using bundler, or your deploy process is more complicated, you may need to tweak the default binary locations or callback ordering.

See `lib/eye/patch/capistrano.rb` for a list of available configuration options.

If you're on Capistrano 3, you'll want:

    require "eye/patch/capistrano3"

If you're specifically using `Eye::Patch` in conjunction with a Rails project, you may need to add the following to your deploy file:

    set :eye_env, -> { {rails_env: fetch(:rails_env)} }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Coming Soon

- Process templates for commonly-used libraries (unicorn, sidekiq, delayed_jobs).
