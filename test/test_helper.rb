$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV["HELL_ENABLED"] || ENV['CODECLIMATE_REPO_TOKEN']
  require 'simplecov'
  if ENV['CODECLIMATE_REPO_TOKEN']
    require "codeclimate-test-reporter"
    SimpleCov.start CodeClimate::TestReporter.configuration.profile
  else
    SimpleCov.start
  end
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

#WebMock.disable_net_connect!(allow_localhost: true, allow: 'codeclimate.com:443')

using OBarc::Utils::Helper::ObjectExtensions

class OBarc::Test < MiniTest::Test
end
