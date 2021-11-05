# frozen_string_literal: true

require 'optparse'

require_relative 'loggable'
require_relative 'version'

module SimpleWebFetcher
  class CommandOptionParser
    include Loggable

    module ExeMode
      CONTINUE = :continue
      EXIT_SUCCESS = :exit_success
      EXIT_FAILURE = :exit_failure
    end

    module Message
      NO_URL = 'Invalid Arguments: must specify at least one URL.'
      INVALID_URL = 'Invalid URL: Any URLs must be in format starting at "http://" or "https://".'
    end

    attr_reader :options, :urls

    def initialize(argv = ARGV, logging_io: nil)
      @logging_io = logging_io
      setup_parser_and_parse(argv)
    rescue StandardError => e
      log_error("#{e.class} is occured. #{e.message}")
      print_help
      @exe_mode = ExeMode::EXIT_FAILURE
    ensure
      continue_or_exit
    end

    def browser
      @options[:browser]
    end

    def show_metadata?
      !!@options[:show_metadata]
    end

    def debug?
      !!@options[:debug]
    end

    private

    def setup_parser_and_parse(argv)
      @options = {}
      @exe_mode = ExeMode::CONTINUE
      @parser = OptionParser.new do |opts|
        opts.banner = 'Usage: simple_web_fetcher.rb [options] http://example.com/one.html [http://example.com/two.html]'

        opts.on('--chrome', 'Uses chrome') do
          @options[:browser] = :chrome
        end

        opts.on('--firefox', 'Uses firefox (Default)') do
          @options[:browser] = :firefox
        end

        opts.on('--metadata', 'Prints the metadata of website when fetching') do
          @options[:show_metadata] = true
        end

        opts.on('--debug', 'Prints debug level logs') do
          @options[:debug] = true
        end

        opts.on('-v', '--version', 'Prints the SimpleWebFetcher version') do
          print_version
          @exe_mode = ExeMode::EXIT_SUCCESS
        end

        opts.on('-h', '--help', 'Prints this help') do
          print_help
          @exe_mode = ExeMode::EXIT_SUCCESS
        end
      end
      @urls = @parser.parse!(argv)
    end

    def continue_or_exit
      case @exe_mode
      when ExeMode::CONTINUE
        is_valid, err_msg = valid_urls?
        unless is_valid
          log(err_msg)
          exit(false)
        end
        nil # continue to main procedure
      when ExeMode::EXIT_SUCCESS
        exit(true)
      when ExeMode::EXIT_FAILURE
        exit(false)
      else
        log_error("ExeMode is unknown. @exe_mode:#{@exe_mode}")
        print_help
        exit(false)
      end
    end

    def print_version
      log(VERSION)
    end

    def print_help
      log(@parser.help) # TODO
    end

    def valid_urls?
      return false, Message::NO_URL if @urls.empty?
      unless @urls.all? { |url| url.start_with?('http://') || url.start_with?('https://') }
        return false, Message::INVALID_URL
      end

      [true, nil]
    end
  end
end
