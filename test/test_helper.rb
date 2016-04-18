$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV["HELL_ENABLED"]
  require 'simplecov'
  SimpleCov.start
  SimpleCov.merge_timeout 3600
end

require 'obarc'

require 'minitest/autorun'
# require 'webmock/minitest'
require 'yaml'

if ENV["HELL_ENABLED"]
  require "minitest/hell"
else
  require "minitest/pride"
end

using OBarc::Utils::Helper::ObjectExtensions

class OBarc::Test < MiniTest::Test
end