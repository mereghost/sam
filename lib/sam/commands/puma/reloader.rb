# frozen_string_literal: true

module Sam
  module CLI
    module Commands
      module Puma
        class Reloader < Hanami::CLI::Command
          # rubocop:disable Metrics/LineLength
          desc 'Monitor an already running unicorn'
          option :config, type: :path, desc: 'The path to the server configuration', default: 'config/unicorn/production.rb', aliases: ['-c']
          option :timeout, type: :integer, desc: 'The number of seconds to wait for starting the unicorn server', aliases: ['-t']
          example [
            '--config=config/server_settings.rb  #Starts the server in production mode using the config/server_settings.rb config file'
          ]
          # rubocop:enable Metrics/LineLength

          def call(config:)
            path = Pathname.new(Dir.pwd).join(config)
            Sam::Puma::Cloner.new.call(path)
          rescue Errors::ProcessNotFound
            warn 'Puma exited'
            exit 1
          end
        end
      end
    end
  end
end