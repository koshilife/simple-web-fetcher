#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'command_option_parser'
require_relative 'fetcher'

module SimpleWebFetcher
  def fetch
    opts = CommandOptionParser.new(ARGV)
    fetcher = Fetcher.new(opts)
    fetcher.fetch_and_save_all(opts.urls)
  end
  module_function :fetch
end

SimpleWebFetcher.fetch
