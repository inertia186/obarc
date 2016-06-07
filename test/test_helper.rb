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
require 'webmock/minitest' unless ENV['TEST_NET']
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
  
  def stub_500_error_odd_string_length ( method, pattern, & block )
    @stub_500_error_odd_string_length ||= if defined? WebMock
      stub_request(method, pattern).
        to_return(status: 500, body: fixture('500_error_odd_string_length.html'))
    end
    
    if !!block
      yield
      if !!@stub_500_error_odd_string_length
        assert_requested @stub_500_error_odd_string_length, times: 1 and remove_request_stub @stub_500_error_odd_string_length
      end
    end
  end
  
  def stub_401_unauthorized ( method, pattern, & block )
    @stub_401_error_odd_string_length ||= if defined? WebMock
      stub_request(method, pattern).
        to_return(status: 401, body: fixture('401_unauthorized.html'))
    end
    
    if !!block
      yield
      if !!@stub_401_error_odd_string_length
        assert_requested @stub_401_error_odd_string_length, times: 1 and remove_request_stub @stub_401_error_odd_string_length
      end
    end
  end
  
  def stub_connection_refused ( method, pattern, & block )
    @stub_connection_refused ||= if defined? WebMock
      stub_request(method, pattern).
        to_raise(Errno::ECONNREFUSED)
    end
    
    if !!block
      yield
      if !!@stub_connection_refused
        assert_requested @stub_connection_refused, times: 1 and remove_request_stub @stub_connection_refused
      end
    end
  end
  
  def stub_timeout ( method, pattern, & block )
    @stub_timeout ||= if defined? WebMock
      stub_request(method, pattern).to_timeout
    end
    
    if !!block
      yield
      if !!@stub_timeout
        assert_requested @stub_timeout, times: 1 and remove_request_stub @stub_timeout
      end
    end
  end
  
  def method_missing(m, *args, &block)
    if m =~ /^stub_/
      if defined? WebMock
        verb = m.to_s.split('_')
        method = verb[1].to_sym
        json_file = action = verb[2..-1].join('_')
        action = args[0][:as] if !!args[0] && !!args[0][:as]
        times = args[0][:times] if !!args[0] && !!args[0][:times]
        
        status = if !!args[0] && !!args[0][:status]
          args[0][:status]
        else
          200
        end
        
        stub = if m =~ /get_image/
          hash = args[0][:hash]
          options = if !!image = fixture("#{hash}.jpg")
            {status: status, body: image}
          else
            {status: 404}
          end
          
          stub_request(method, /get_image\?hash=#{hash.to_s}/).to_return(options)
        else
          options = if !!json = fixture("#{json_file}.json")
            {status: status, body: json}
          else
            {status: 404}
          end
          
          stub_request(method, /#{action}/).to_return(options)
        end
      end
        
      if !!block
        yield.tap do |result|
          if !!stub
            assert_requested stub, times: times
            remove_request_stub stub 
          end
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
