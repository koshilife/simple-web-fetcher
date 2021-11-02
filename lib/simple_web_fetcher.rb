#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'version'

module SimpleWebFetcher
  class Fetcher
    def self.main
      puts "Hello SimpleWebFetcher! v#{VERSION}"
    end
  end
end

SimpleWebFetcher::Fetcher.main
