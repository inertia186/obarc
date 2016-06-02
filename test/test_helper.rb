$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV["HELL_ENABLED"] || ENV['CODECLIMATE_REPO_TOKEN']
  require 'simplecov'
  if ENV['CODECLIMATE_REPO_TOKEN']
    require "codeclimate-test-reporter"
    SimpleCov.start CodeClimate::TestReporter.configuration.profile
    CodeClimate::TestReporter.start
  else
    SimpleCov.start
  end
  SimpleCov.merge_timeout 3600
end

require 'obarc'

require 'minitest/autorun'
require 'webmock/minitest'
require 'yaml'
require 'pry'

if ENV["HELL_ENABLED"]
  require "minitest/hell"
else
  require "minitest/pride"
end

if defined? WebMock
  WebMock.disable_net_connect!(allow_localhost: false, allow: 'codeclimate.com:443')
end

using OBarc::Utils::Helper::ObjectExtensions

class OBarc::Test < MiniTest::Test
  def stub_post_login ( & block )
    
    @stub_login ||= if defined? WebMock
      stub_request(:post, /login/).
        to_return(status: 200, body: '{"success": true}', headers: {'Set-Cookie' => 'TWISTED_SESSION=e564e3329ec7a205ee588bfc32c98ac3; Path=/'})
    end
      
    if !!block
      yield
      if !!@stub_login
        assert_requested @stub_login, times: 1 and remove_request_stub @stub_login
      end
    end
  end
  
  def method_missing(m, *args, &block)
    if m =~ /^stub_/
      return unless defined? WebMock
      
      verb = m.to_s.split('_')
      method = verb[1].to_sym
      json_file = action = verb[2..-1].join('_')
      action = args[0][:as] if !!args[0] && !!args[0][:as]
      times = args[0][:times] if !!args[0] && !!args[0][:times]
      
      stub = if m =~ /get_image/
        hash = args[0][:hash]
        options = if !!image = fixture("#{hash}.jpg")
          {status: 200, body: image}
        else
          {status: 404}
        end
        
        stub_request(method, /get_image\?hash=#{hash.to_s}/).
          to_return(options)
      else
        options = if !!json = fixture("#{json_file}.json")
          {status: 200, body: json}
        else
          {status: 404}
        end
        
        stub_request(method, /#{action}/).
          to_return(options)
      end
        
      if !!block && !!stub
        yield.tap do |result|
          assert_requested stub, times: times and remove_request_stub stub
          return result
        end
      end
      
      stub
    else
      super
    end
  end
private
  def fixture(fixture)
    if File.exist?(File.join(fixture_path, fixture))
      File.open(File.join(fixture_path, fixture), 'rb')
    end
  end
  
  def fixture_path
    @support_path ||= 'test/fixtures'
  end
end
