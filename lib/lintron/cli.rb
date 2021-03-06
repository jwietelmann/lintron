require 'optparse'
require 'rubygems'
require 'active_support/all'
require 'filewatcher'
require_relative '../../app/models/local_pr_alike'

module Lintron
  # Handles setting up flags for CLI runs based on defaults, linty_rc, and
  # command line arguments
  class CLI
    def initialize
      @options = {}
      OptionParser.new do |opts|
        opts.banner = 'Usage: linty [options]'

        opts.on('--watch', 'Watch for changes') do |v|
          @options[:watch] = v
        end
      end.parse!
    end

    def go
      if config[:watch]
        go_watch
      else
        go_once
      end
    end

    def go_watch
      system('clear')
      go_once

      watcher.watch do |filename|
        system('clear')
        puts "Re-linting because of #{filename}\n\n"
        go_once
      end
    end

    def watcher
      FileWatcher.new(['*', '**/*'], exclude: config[:watch_exclude])
    end

    def go_once
      violations = Lintron::API.new(config[:base_url]).violations(pr)
      puts Lintron::TerminalReporter.new.format_violations(violations)
    end

    def pr
      LocalPrAlike.from_branch(base_branch)
    end

    def base_branch
      config[:base_branch]
    end

    def config
      defaults
        .merge(validated_config_from_file)
        .merge(@options)
        .merge(
          {
            base_branch: ARGV[0],
          }.compact,
        )
    end

    def defaults
      {
        base_branch: 'origin/develop',
        watch_exclude: [
          '**/*.log',
          'tmp/**/*',
        ],
      }
    end

    def validated_config_from_file
      config = config_from_file

      unless config.key?(:base_url)
        raise('.linty_rc missing required key: base_url')
      end

      config
    end

    def config_from_file
      file_path = File.join(`git rev-parse --show-toplevel`.strip, '.linty_rc')

      raise('.linty_rc is missing.') unless File.exist?(file_path)

      begin
        JSON.parse(File.read(file_path)).symbolize_keys
      rescue JSON::ParserError
        raise('Malformed .linty_rc')
      end
    end
  end
end
