# frozen_string_literal: true

require 'fileutils'
require 'selenium-webdriver'

require_relative 'loggable'

module SimpleWebFetcher
  class Fetcher
    include Loggable

    DEFAULT_DOWNLOADS_DIR_PATH = File.expand_path(File.join(__dir__, '../tmp/downloads'))
    DEFAULT_HISTORY_DATA_PATH = File.expand_path(File.join(__dir__, '../tmp/history.json'))

    def initialize(cmd_options = nil, show_metadata: false, is_debug: false, logging_io: nil)
      @cmd_options = cmd_options
      @show_metadata = show_metadata
      @is_debug = is_debug
      @logging_io = logging_io

      ready_saving_io
      setup_driver
    end

    def fetch_and_save_all(urls)
      result = { total: 0, success: 0, failure: 0 }
      return result if urls.nil? || urls.empty?

      urls.each do |url|
        fetch_and_save(url) ? result[:success] += 1 : result[:failure] += 1
        result[:total] += 1
      end
      result
    end

    def fetch_and_save(url)
      log_debug("start fetching. url:#{url}")
      @driver.get(url)
      save_current_page_source(url)
      last_fetched_at = update_fetched_history(url)
      log_current_page_metadata(last_fetched_at) if show_metadata?
      true
    rescue StandardError => e
      log_debug_for_exception(e)
      log_error("failed fetching or saving page source. url:#{url}")
      false
    end

    private

    def ready_saving_io
      check_history_file
      check_downloads_dir
    rescue StandardError
      exit(false)
    end

    def check_history_file
      file_path = history_data_path
      return unless File.exist?(file_path)
      return if File.file?(file_path)

      log_error("history data file is NOT a file. path:#{file_path}")
      raise
    end

    def check_downloads_dir
      dir_path = downloads_dir_path
      unless File.exist?(dir_path)
        FileUtils.mkdir_p(dir_path)
        log_debug("create directory as saving directory. path:#{dir_path}")
        return
      end
      return if File.directory?(dir_path)

      log_error("downloads dir is NOT a directory. path:#{dir_path}")
      raise
    end

    def setup_driver
      setup_local_chrome_driver
    rescue StandardError => e
      log_debug_for_exception(e)
      err_msg = 'The webdriver connection is something wrong. You need to add chromedriver to your $PATH.'
      err_msg += ' You can get more information if use with `--debug` option.' unless debug?
      log_error(err_msg)
      exit(false)
    end

    def setup_local_chrome_driver
      @driver = Selenium::WebDriver.for(:chrome, capabilities: chrome_options)
    end

    def chrome_options
      opts = Selenium::WebDriver::Options.chrome
      opts.add_argument('--headless')
      opts.add_argument('--no-sandbox')
      opts
    end

    def save_current_page_source(url)
      dir_path = downloads_dir_path
      file_path = File.join(dir_path, saving_file_name(url))
      File.open(file_path, 'w+') do |f|
        f.write(@driver.page_source)
      end
      log_debug("saved the page data successfully. path:#{file_path}")
    rescue StandardError => e
      log_debug_for_exception(e)
      log_error("failed to save the page data. url:url, current_url:#{@driver.current_url}")
    end

    def saving_file_name(url)
      "#{URI.parse(url).host}_#{Time.now.utc.strftime('%Y%m%d_%H%M%S')}.html"
    end

    def log_current_page_metadata(last_fetched_at)
      count_a_tag = @driver.find_elements(tag_name: 'a')&.length.to_i
      count_img_tag = @driver.find_elements(tag_name: 'img')&.length.to_i
      log("site: #{current_page_host}")
      log("num_links: #{count_a_tag}")
      log("images: #{count_img_tag}")
      log("last_fetch: #{last_fetched_at.nil? ? '(first time)' : Time.at(last_fetched_at).utc}")
    end

    def current_page_host
      uri = URI.parse(@driver.current_url)
      uri.host
    rescue StandardError => e
      log_debug_for_exception(e)
      nil
    end

    def update_fetched_history(url)
      data = load_history_file
      last_fetched_at = data&.dig(url, 'last_fetched_at')

      data ||= {}
      data[url] ||= {}
      data[url]['last_fetched_at'] = Time.now.to_i
      save_history_file(data)

      log_debug('updated history data.')
      last_fetched_at
    rescue StandardError => e
      log_debug_for_exception(e)
      log_error('failed to update history data.')
      nil
    end

    def load_history_file
      file_path = history_data_path
      return unless File.exist?(file_path)

      json_data = File.read(file_path)
      JSON.parse(json_data)
    end

    def save_history_file(data)
      file_path = history_data_path
      File.open(file_path, 'w+') do |f|
        f.write(data.to_json)
      end
    end

    def show_metadata?
      @show_metadata || !!@cmd_options&.show_metadata?
    end

    def debug?
      @is_debug || !!@cmd_options&.debug?
    end

    def downloads_dir_path
      DEFAULT_DOWNLOADS_DIR_PATH
    end

    def history_data_path
      DEFAULT_HISTORY_DATA_PATH
    end
  end
end
