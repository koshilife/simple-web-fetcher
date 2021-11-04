# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require_relative '../lib/fetcher'

module SimpleWebFetcher
  class BaseTest < Minitest::Test
  end
end
