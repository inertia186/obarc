require 'obarc/utils/helper'
require 'obarc/utils/exceptions'

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
    
    # GET api/v1/get_image
    def get_image(hash, options = {})
      url = "#{build_base_url(options)}/get_image"
      execute method: :get, url: url, headers:
        build_headers(options).merge(params: {hash: hash}.compact)
    end
    
    # GET api/v1/profile
    def get_profile(guid = nil, options = {})
      url = "#{build_base_url(options)}/profile"
      execute method: :get, url: url, headers:
        build_headers(options).merge(params: {guid: guid}.compact)
    end
    
    # GET api/v1/get_listings
    def get_listings(guid = nil, options = {})
      url = "#{build_base_url(options)}/get_listings"
      execute method: :get, url: url, headers:
        build_headers(options).merge(params: {guid: guid}.compact)
    end
    
    # GET api/v1/get_followers
    def get_followers(guid = nil, options = {})
      url = "#{build_base_url(options)}/get_followers"
      execute method: :get, url: url, headers:
        build_headers(options).merge(params: {guid: guid}.compact)
    end
    
    # GET api/v1/get_following
    def get_following(guid = nil, options = {})
      url = "#{build_base_url(options)}/get_following"
      execute method: :get, url: url, headers:
        build_headers(options).merge(params: {guid: guid}.compact)
    end
    
    # POST api/v1/follow
    def post_follow(guid, options = {})
      url = "#{build_base_url(options)}/follow"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: {guid: guid}.compact)
    end
    
    # POST api/v1/unfollow
    def post_unfollow(guid, options = {})
      url = "#{build_base_url(options)}/unfollow"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: {guid: guid}.compact)
    end
    
    # POST api/v1/profile
    def post_profile(profile, options = {})
      url = "#{build_base_url(options)}/profile"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: profile.compact)
    end
    
    # POST api/v1/social_accounts
    def post_social_accounts(social_accounts, options = {})
      url = "#{build_base_url(options)}/social_accounts"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: social_accounts.compact)
    end
    
    # DELETE api/v1/social_accounts
    def delete_social_accounts(social_accounts, options = {})
      url = "#{build_base_url(options)}/social_accounts"
      execute method: :delete, url: url, headers:
        build_headers(options).merge(params: social_accounts.compact)
    end
    
    # GET api/v1/contracts
    def get_contracts(id = nil, guid = nil, options = {})
      if !!id && id.size != 40
        raise Utils::Exceptions::OBarcError, "id must be 40 characters, if present (was: #{id.size})"
      elsif !!guid && guid.size != 40
        raise Utils::Exceptions::OBarcError, "guid must be 40 characters, if present (was: #{guid.size})"
      end
      
      url = "#{build_base_url(options)}/contracts"
      execute method: :get, url: url, headers:
        build_headers(options).merge(params: {id: id, guid: guid}.compact)
    end
    
    # POST api/v1/contracts
    def post_contract(contract, options = {})
      url = "#{build_base_url(options)}/contracts"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: contract.compact)
    end
    
    # DELETE api/v1/contracts
    def delete_contract(id, options = {})
      url = "#{build_base_url(options)}/contracts"
      execute method: :delete, url: url, headers:
        build_headers(options).merge(params: {id: id}.compact)
    end
    
    # GET api/v1/shutdown
    def get_shutdown(options = {})
      url = "#{build_base_url(options)}/shutdown"
      execute method: :get, url: url, headers: build_headers(options)
    end
    
    # POST api/v1/make_moderator
    def post_make_moderator(options = {})
      url = "#{build_base_url(options)}/make_moderator"
      execute method: :post, url: url, headers: build_headers(options)
    end
    
    # POST api/v1/unmake_moderator
    def post_unmake_moderator(options = {})
      url = "#{build_base_url(options)}/unmake_moderator"
      execute method: :post, url: url, headers: build_headers(options)
    end
    
    # POST api/v1/purchase_contracts
    def post_purchase_contract(purchase_contract, options = {})
      url = "#{build_base_url(options)}/purchase_contract"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: purchase_contract.compact)
    end
    
    # POST api/v1/confirm_order
    def post_confirm_order(confirm_order, options = {})
      url = "#{build_base_url(options)}/confirm_order"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: confirm_order.compact)
    end
    
    # POST api/v1/upload_image
    def post_upload_image(options = {})
      url = "#{build_base_url(options)}/upload_image"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: {
          image: options[:image],
          avatar: options[:avatar],
          header: options[:header],
        }.compact)
    end
    
    # POST api/v1/complete_order
    def post_complete_order(complete_order, options = {})
      url = "#{build_base_url(options)}/complete_order"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: complete_order.compact)
    end
    
    # POST api/v1/settings
    def post_settings(settings, options = {})
      url = "#{build_base_url(options)}/settings"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: settings.compact)
    end
    
    # GET api/v1/settings
    def get_settings(options = {})
      url = "#{build_base_url(options)}/settings"
      execute method: :get, url: url, headers: build_headers(options)
    end
    
    # GET api/v1/connected_peers
    def get_connected_peers(options = {})
      url = "#{build_base_url(options)}/connected_peers"
      execute method: :get, url: url, headers: build_headers(options)
    end
    
    # GET api/v1/routing_table
    def get_routing_table(options = {})
      url = "#{build_base_url(options)}/routing_table"
      execute method: :get, url: url, headers: build_headers(options)
    end
    
    # GET api/v1/get_notifications
    def get_notifications(options = {})
      url = "#{build_base_url(options)}/get_notifications"
      execute method: :get, url: url, headers: build_headers(options)
    end
    
    # POST api/v1/mark_notification_as_read
    def post_mark_notification_as_read(id, options = {})
      url = "#{build_base_url(options)}/mark_notification_as_read"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: {id: id}.compact)
    end
    
    # POST api/v1/broadcast
    def post_broadcast(message, options = {})
      url = "#{build_base_url(options)}/broadcast"
      execute method: :post, url: url, headers:
        build_headers(options).merge(params: {message: message}.compact)
    end
    
    # GET api/v1/btc_price
    def get_btc_price(options = {})
      url = "#{build_base_url(options)}/btc_price"
      execute method: :get, url: url, headers: build_headers(options)
    end
  private
    def execute(options = {})
      RestClient::Request.execute(options.merge(timeout: DEFAULT_TIMEOUT))
    end
    
    def build_authentication(options = {})
      if options.kind_of? Session
        {username: options.username, password: options.password}
      else
        options.select { |key| key == :username || key == :password }
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
        options.select { |key| key == :cookies }
      end
    end
  end
end