require 'obarc/utils/helper'
require 'obarc/utils/exceptions'
require 'uri'
require 'base64'

module OBarc
  module Api
    extend self
    using Utils::Helper::ObjectExtensions
    
    DEFAULT_TIMEOUT = 60 * 60 * 1
    
    # POST api/v1/login
    def post_login(options = {})
      url = "#{build_base_url(options)}/login"
      auth = build_authentication(options)
      
      raise Utils::Exceptions::OBarcError, 'Login username and password required.' if auth.empty?

      execute method: :post, url: url, headers: {params: auth}
    end
    
    def method_missing(m, *args, &block)
      # Many of the calls to restapi.py are uniform enough for DRY code, but the
      # ones that aren't are mapped here.
      
      rest_method, endpoint, params, options = case m
      when :get_image then [:get, 'get_image', args[0], args[1]]
      when :get_listings then [:get, 'get_listings', args[0], args[1]]
      when :get_followers then [:get, 'get_followers', args[0], args[1]]
      when :get_following then [:get, 'get_following', args[0], args[1]]
      when :post_contract then [:post, 'contracts', args[0], args[1]]
      when :delete_contract then [:delete, 'contracts', args[0], args[1]]
      when :get_notifications then [:get, 'get_notifications', nil, args[0]]
      else
        verb = m.to_s.split('_')
        a = [verb[0].to_sym, verb[1..-1].join('_')]
        a << if args.size == 1
          nil
        else
          args[0]
        end
        a << args[args.size - 1]
      end
      
      url = "#{build_base_url(options)}/#{endpoint}" if !!endpoint && !!options
      if !!rest_method && !!url && !!options
        headers = build_headers(options)
        headers = headers.merge(params: params.compact) if !!params
        return execute method: rest_method, url: url, headers: headers
      end
          
      super
    end
    
    # POST api/v1/upload_image
    def post_upload_image(options = {})
      elements = [:image, :avatar, :header]
      params = options.slice(*elements)
      options = options.delete_if { |k, v| elements.include? k }
      
      url = "#{build_base_url(options)}/upload_images"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: params.compact)
    end
    
    # GET api/v1/contracts
    def get_contracts(contracts, options = {})
      id = contracts[:id]
      guid = contracts[:guid]
      
      if !!id && id.size != 40
        raise Utils::Exceptions::OBarcError, "id must be 40 characters, if present (was: #{id.size})"
      elsif !!guid && guid.size != 40
        raise Utils::Exceptions::OBarcError, "guid must be 40 characters, if present (was: #{guid.size})"
      end
      
      url = "#{build_base_url(options)}/contracts"
      execute method: :get, url: url, headers:
        build_headers(options).merge(params: contracts.compact)
    end
  private
    def execute(options = {})
      if !!options[:headers][:params]
        params = options[:headers].delete(:params)
        if params.values.map(&:class).include? Array
          # Dropping to a lower level for parameters since they're more
          # complicated due to the presense of an Array.  Note that these
          # parameters go # outside the header.
          options[:url] += "?#{URI::encode_www_form params}"
        elsif params.values.map(&:class).any? { |c| [Tempfile, File].include?(c) }
          # Handling (possibly) large files.
          options[:payload] = {multipart: true}
          params.each do |k, v|
            options[:payload][k] = Base64.strict_encode64(v.read)
          end
        else
          options[:headers][:params] = params
        end
      end
      
      RestClient::Request.execute(options.merge(timeout: DEFAULT_TIMEOUT))
    rescue RestClient::ServerBrokeConnection
      # TODO Log?
    end
    
    def build_authentication(options = {})
      if options.kind_of? Session
        {username: options.username, password: options.password}
      else
        options.slice(:username, :password)
      end.compact
    end
    
    def build_base_url(options = {})
      if options.kind_of? Session
        options.base_url
      else
        options[:base_url]
      end
    end
    
    def build_headers(options = {})
      if options.kind_of? Session
        {cookies: options.cookies}
      else
        options.slice(:cookies)
      end
    end
  end
end