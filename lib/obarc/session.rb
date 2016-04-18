require 'obarc/api'

module OBarc
  class Session
    attr_accessor :cookies, :base_url, :username, :password
    
    DEFAULT_OPTIONS = {
      protocol: 'http',
      server_host: 'localhost',
      server_port: '18469',
      api_version: 'v1'
    }
    
    def initialize(options = {})
      @protocol = options[:protocol] || DEFAULT_OPTIONS[:protocol]
      @server_host = options[:server_name] || DEFAULT_OPTIONS[:server_host]
      @server_port = options[:server_port] || DEFAULT_OPTIONS[:server_port]
      @api_version = options[:api_version] || DEFAULT_OPTIONS[:api_version]
      @username = options[:username]
      @password = options[:password]
      @base_url = options[:base_url] || base_url
      @cookies = options[:cookies] || Api::post_login(self).cookies
    end
    
    def base_url
      "#{@protocol}://#{@server_host}:#{@server_port}/api/#{@api_version}"
    end
    
    def image(image); Api::get_image(image, self); end
    def profile(profile = nil); JSON[Api::get_profile(profile, self)]; end
    def social_accounts(profile = nil); JSON[Api::get_profile(profile, self)]['profile']['social_accounts']; end
    def listings(listings = nil); JSON[Api::get_listings(listings, self)]; end
    def followers(followers = nil); JSON[Api::get_followers(followers, self)]; end
    def following(following = nil); JSON[Api::get_following(following, self)]; end
    def follow(follow); JSON[Api::post_follow(follow, self)]; end
    def unfollow(unfollow); JSON[Api::post_unfollow(unfollow, self)]; end
    def profile=(profile = {}); JSON[Api::post_profile(profile, self)]; end
    def add_social_account(social_account = {}); JSON[Api::post_social_accounts(social_account, self)]; end
    def delete_social_account(social_account = {}); JSON[Api::delete_social_accounts(social_account, self)]; end
    def contracts(contracts); JSON[Api::get_contracts(contracts, self)]; end
    def add_contract(contract = {}); JSON[Api::post_contract(contract, self)]; end
    def delete_contract(contract = {}); JSON[Api::delete_contract(contract, self)]; end
    def make_moderator; JSON[Api::post_make_moderator(self)]; end
    def unmake_moderator; JSON[Api::post_unmake_moderator(self)]; end
    def purchase_contract(purchase_contract = {}); JSON[Api::post_purchase_contract(purchase_contract, self)]; end
    def confirm_order(confirm_order = {}); JSON[Api::post_confirm_order(confirm_order, self)]; end
    def upload_image(image = {}); JSON[Api::post_upload_image(image.merge(cookies: cookies, base_url: base_url))]; end
    def complete_order(complete_order = {}); JSON[Api::post_complete_order(complete_order, self)]; end
    def settings=(settings); JSON[Api::post_settings(settings, self)]; end
    def settings; JSON[Api::get_settings(self)]; end
    def connected_peers; JSON[Api::get_connected_peers(self)]; end
    def notifications; JSON[Api::get_notifications(self)]; end
    def mark_notification_as_read(notification = nil); JSON[Api::post_mark_notification_as_read(notification, self)]; end
    def broadcast=(message); JSON[Api::post_broadcast(message, self)]; end
    def btc_price; JSON[Api::get_btc_price(self)]; end
    def routing_table; JSON[Api::get_routing_table(self)]; end
    
    def shutdown!
      begin
        Api::get_shutdown(self)
      rescue Errno::ECONNREFUSED => e
        # TODO Add logging.
      end
    end
  end
end
