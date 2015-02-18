require 'thor'

module GrosCalin

  class CLI < Thor

    desc "start", "Starts the server"
    option :port, aliases: %w(p), type: :numeric, default: '3313',
        desc: "The port number to assign"
    option :daemon, aliases: %w(d), type: :boolean, default: false,
      desc: "Place the server process in the background"
    option :config, aliases: %w(-c), type: :string,
      desc: 'Override path to configuration file', default: './config.yml'

    def start
      command = "thin -R #{config_ru} start -p #{options[:port]}"
      if options[:config]
        command.prepend "export GROS_CALIN_CONFIG=#{options[:config]}; "
      end
      command << ' -d' if options[:daemon]
      system command
    end

    desc "stop", "Stops the server"

    def stop
      system "thin stop"
    end

    default_task :start

    no_tasks do

      def config_ru
        File.expand_path(File.join(File.dirname(__FILE__), '../../config.ru'))
      end

    end

  end

end
