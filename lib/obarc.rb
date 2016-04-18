require 'obarc/version'
require 'json'
require 'rest-client'

module OBarc
  require 'obarc/utils/helper'
  require 'obarc/session'
  extend self
  
  def login!(options)
    options[:base_url] ||= "#{options[:protocol]}://#{options[:server_host]}:#{options[:server_port]}/api/#{options[:api_version]}"
    Session.new(username: options[:username], password: options[:password], cookies: Api.post_login(options).cookies)
  end
end