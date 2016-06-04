require 'obarc/utils/helper'
require 'obarc/utils/exceptions'
require 'uri'
require 'base64'

module OBarc
  module Api
    extend self
    using Utils::Helper::ObjectExtensions
    
    DEFAULT_TIMEOUT = 60 * 60 * 1
    
    VALID_ACTIONS = {
      get: %i(image profile listings followers following contracts shutdown
        settings connected_peers routing_table notifications chat_messages
        chat_conversations sales purchases order cases order_messages ratings
        btc_price),
      post: %i(login follow unfollow profile social_accounts
        contract make_moderator unmake_moderator purchase_contract
        confirm_order upload_image complete_order settings
        mark_notification_as_read broadcast mark_chat_message_as_read
        check_for_payment dispute_contract close_dispute release_funds refund
        mark_discussion_as_read),
      delete: %i(social_accounts contract chat_conversation)
    }.freeze
    
    # POST api/v1/login
    def post_login(options = {})
      url = "#{build_base_url(options)}/login"
      auth = build_authentication(options)
      
      raise Utils::Exceptions::OBarcError, 'Login username and password required.' if auth.empty?

      execute method: :post, url: url, headers: {params: auth},
        verify_ssl: build_verify_ssl(options)
    end
    
    def ping(options = {})
      execute(method: :get,
        url: "#{build_base_url(options)}/connected_peers?_=#{Time.now.to_i}",
        headers: build_headers(options), verify_ssl: build_verify_ssl(options))
    end
    
    def respond_to_missing?(m, include_private = false)
      verb = m.to_s.split('_')
      rest_method = verb[0].to_sym
      return false unless VALID_ACTIONS.keys.include?(rest_method)
      
      endpoint = verb[1..-1].join('_')
      return false if endpoint.nil?
      
      VALID_ACTIONS[rest_method].include?(endpoint.to_sym)
    end
    
    def method_missing(m, *args, &block)
      super unless respond_to_missing?(m)
      
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
      when :get_chat_conversations then [:get, 'get_chat_conversations', nil, args[0]]
      when :get_sales then [:get, 'get_sales', nil, args[0]]
      when :get_purchases then [:get, 'get_purchases', nil, args[0]]
      when :get_cases then [:get, 'get_cases', nil, args[0]]
      when :get_ratings then [:get, 'get_ratings', args[0], args[1]]
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
        return execute method: rest_method, url: url, headers: headers,
          verify_ssl: build_verify_ssl(options)
      end
          
      raise Utils::Exceptions::OBarcError, "Did not handle #{m} as expected, arguments: #{args}"
    end
    
    # POST api/v1/upload_image
    def post_upload_image(options = {})
      elements = [:image, :avatar, :header]
      params = options.slice(*elements)
      options = options.delete_if { |k, v| elements.include? k }
      
      url = "#{build_base_url(options)}/upload_images"
      execute method: :post, url: url,
        headers: build_headers(options).merge(params: params.compact),
        verify_ssl: build_verify_ssl(options)
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
      execute method: :get, url: url,
        headers: build_headers(options).merge(params: contracts.compact),
        verify_ssl: build_verify_ssl(options)
    end
    
    # GET api/v1/get_chat_messages
    def get_chat_messages(chat_messages, options = {})
      guid = chat_messages[:guid]
      
      if guid.nil? || guid.size != 40
        raise Utils::Exceptions::OBarcError, "guid must be present, 40 characters (was: #{guid.inspect})"
      end
      
      url = "#{build_base_url(options)}/get_chat_messages"
      execute method: :get, url: url,
        headers: build_headers(options).merge(params: chat_messages.compact),
        verify_ssl: build_verify_ssl(options)
    end
    
    # GET api/v1/get_order
    def get_order(order, options = {})
      order_id = order[:order_id]
      
      if order_id.nil?
        raise Utils::Exceptions::OBarcError, 'order_id must be present'
      end
      
      url = "#{build_base_url(options)}/get_order"
      execute method: :get, url: url,
        headers: build_headers(options).merge(params: order.compact),
        verify_ssl: build_verify_ssl(options)
    end
  private
    def execute(options = {})
      if options[:method] == :post
        options[:headers][:content_type] = 'application/x-www-form-urlencoded'
      end
        
      if !!options[:headers][:params]
        params = options[:headers].delete(:params)
        
        if params.values.map(&:class).include? Array
          # Dropping to a lower level for parameters since they're more
          # complicated due to the presense of an Array.  Note that these
          # parameters go # outside the header.
          options[:url] += "?#{URI::encode_www_form params}"
        elsif params.values.map(&:class).any? { |c| [Tempfile, File, StringIO].include?(c) }
          # Handling (possibly) large files.
          options[:payload] = {multipart: true}
          params.each do |k, v|
            if v.respond_to? :read
              options[:payload][k] = Base64.strict_encode64(v.read)
            else
              options[:payload][k] = v
              # FIXME Might want to warn that we are possibly mixing multipart
              # with simple payload.
            end
          end
        else
          options[:headers][:params] = params
        end
      end
      
      RestClient::Request.execute(options.merge(timeout: DEFAULT_TIMEOUT))
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
      elsif options.kind_of? Hash
        options[:base_url]
      else
        raise Utils::Exceptions::OBarcError, "Unable to build base URL using: #{options.inspect}, expected a OBarc::Session or Hash."
      end
    end
    
    def build_headers(options = {})
      if options.kind_of? Session
        {cookies: options.cookies}
      else
        options.slice(:cookies)
      end
    end
    
    def build_verify_ssl(options = {})
      if options.kind_of? Session
        !!options.verify_ssl
      else
        !!options[:verify_ssl]
      end
    end
  end
end