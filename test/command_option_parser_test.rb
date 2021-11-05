# frozen_string_literal: true

require 'test_helper'
require 'stringio'

require_relative '../lib/command_option_parser'

module SimpleWebFetcher
  # test cases for SimpleWebFetcher::CommandOptionParser
  class CommandOptionParserTest < BaseTest
    def setup
      @subject = SimpleWebFetcher::CommandOptionParser
      @dummy_io = StringIO.new
      @valid_url1 = 'http://example.com/1'
      @valid_url2 = 'https://example.com/2'
      @invalid_url = 'invalid-url'
      begin
        option = SimpleWebFetcher::CommandOptionParser.new([@valid_url1])
        @help_msg = option.instance_variable_get('@parser').help
      rescue StandardError => e
        puts e
        @help_msg = "(ERROR) Failed to get the help message in #{self.class}\##{__method__}"
      end
    end

    def test_that_it_parse_single_url
      argv = [@valid_url1]
      parser = @subject.new(argv, logging_io: @dummy_io)
      assert_equal(argv, parser.urls)
      assert(@dummy_io.string.empty?)

      # check whether is set default value each option
      assert_nil(parser.browser)
      assert_equal(false, parser.show_metadata?)
      assert_equal(false, parser.debug?)
    end

    def test_that_it_parse_multi_url
      argv = [@valid_url1, @valid_url2]
      parser = @subject.new(argv, logging_io: @dummy_io)
      assert_equal(argv, parser.urls)
      assert(@dummy_io.string.empty?)
    end

    def test_that_it_exit_if_no_url
      argv = []
      e = assert_raises(SystemExit) do
        @subject.new(argv, logging_io: @dummy_io)
      end
      assert_equal(1, e.status)
      assert_equal("#{@subject::Message::NO_URL}\n", @dummy_io.string)
    end

    def test_that_it_exit_if_one_invalid_url
      argv1 = [@invalid_url]
      e = assert_raises(SystemExit) do
        @subject.new(argv1, logging_io: @dummy_io)
      end
      assert_equal(1, e.status)
      assert_equal("#{@subject::Message::INVALID_URL}\n", @dummy_io.string)
    end

    def test_that_it_exit_if_multi_urls_included_invalid_url
      argv = [@valid_url1, @valid_url2, @invalid_url]
      e = assert_raises(SystemExit) do
        @subject.new(argv, logging_io: @dummy_io)
      end
      assert_equal(1, e.status)
      assert_equal("#{@subject::Message::INVALID_URL}\n", @dummy_io.string)
    end

    def test_that_it_parse_version_option
      argv = ['-v']
      e = assert_raises(SystemExit) do
        @subject.new(argv, logging_io: @dummy_io)
      end
      assert_equal(0, e.status)
      assert_equal("#{SimpleWebFetcher::VERSION}\n", @dummy_io.string)
    end

    def test_that_it_parse_long_version_option
      argv = ['--version']
      e = assert_raises(SystemExit) do
        @subject.new(argv, logging_io: @dummy_io)
      end
      assert_equal(0, e.status)
      assert_equal("#{SimpleWebFetcher::VERSION}\n", @dummy_io.string)
    end

    def test_that_it_parse_help_option
      argv = ['-h']
      e = assert_raises(SystemExit) do
        @subject.new(argv, logging_io: @dummy_io)
      end
      assert_equal(0, e.status)
      assert_equal("#{@help_msg}\n", @dummy_io.string)
    end

    def test_that_it_parse_long_help_option
      argv = ['--help']
      e = assert_raises(SystemExit) do
        @subject.new(argv, logging_io: @dummy_io)
      end
      assert_equal(0, e.status)
      assert_equal("#{@help_msg}\n", @dummy_io.string)
    end

    def test_that_it_parse_chrome_option
      argv = ['--chrome', @valid_url1]
      parser = @subject.new(argv, logging_io: @dummy_io)
      assert_equal(parser.browser, :chrome)
      assert([@valid_url1], parser.urls)
      assert(@dummy_io.string.empty?)
    end

    def test_that_it_parse_firefox_option
      argv = ['--firefox', @valid_url1]
      parser = @subject.new(argv, logging_io: @dummy_io)
      assert_equal(parser.browser, :firefox)
      assert([@valid_url1], parser.urls)
      assert(@dummy_io.string.empty?)
    end

    def test_that_it_parse_metadata_option
      argv = ['--metadata', @valid_url1]
      parser = @subject.new(argv, logging_io: @dummy_io)
      assert(parser.show_metadata?)
      assert([@valid_url1], parser.urls)
      assert(@dummy_io.string.empty?)
    end

    def test_that_it_parse_debug_option
      argv = ['--debug', @valid_url1]
      parser = @subject.new(argv, logging_io: @dummy_io)
      assert(parser.debug?)
      assert([@valid_url1], parser.urls)
      assert(@dummy_io.string.empty?)
    end

    def test_that_it_parse_many_options
      argv = ['--chrome', '--firefox', '--metadata', '--debug', @valid_url1, @valid_url2]
      parser = @subject.new(argv, logging_io: @dummy_io)
      assert_equal(parser.browser, :firefox)
      assert(parser.show_metadata?)
      assert(parser.debug?)
      assert([@valid_url1, @valid_url2], parser.urls)
      assert(@dummy_io.string.empty?)
    end

    def test_that_it_exit_if_invalid_option
      argv = ['-x', @valid_url1]
      e = assert_raises(SystemExit) do
        @subject.new(argv, logging_io: @dummy_io)
      end
      assert_equal(1, e.status)
      assert_equal("(ERROR) OptionParser::InvalidOption is occured. invalid option: -x\n#{@help_msg}\n",
                   @dummy_io.string)
    end

    def test_that_it_exit_if_exe_mode_is_unknown
      argv = [@valid_url1]
      parser = @subject.new(argv, logging_io: @dummy_io)
      e = assert_raises(SystemExit) do
        parser.instance_variable_set('@exe_mode', :unknown_exe_mode)
        parser.send(:continue_or_exit)
      end
      assert_equal(1, e.status)
      assert_equal("(ERROR) ExeMode is unknown. @exe_mode:unknown_exe_mode\n#{@help_msg}\n",
                   @dummy_io.string)
    end
  end
end
