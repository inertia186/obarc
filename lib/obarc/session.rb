require 'obarc/api'
require 'open-uri'

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
      @server_host = options[:server_host] || DEFAULT_OPTIONS[:server_host]
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
    
    # Check if there's a valid session.
    #
    # @return [Boolean] True if the session is valid.
    def ping
      return false if !(json = Api::ping(self))
      !!JSON[json]['num_peers']
    rescue
      # TODO log?
      false
    end
    
    # Returns the image for the hash specified.
    # @param image [Hash] containing the hash: of the target image, required
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-image
    # @return [Object] The image will be returned in .jpg format.
    def image(image); Api::get_image(image, self); end
    
    # Returns the profile data of the user’s node, or that of a target node.
    #
    # @param profile [Hash] containing the guid: of the target node, optional
    #   * The global unique identifier (guid; 40 character hex string) of the node to get the profile data from
    #   * If the guid is omitted, your own node’s profile will be returned
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-profile
    # @return [Hash]
    def profile(profile = nil); JSON[Api::get_profile(profile, self)]; end
    
    # Returns just the profile's social accounts of the user’s node, or that of a target node.
    #
    # @param profile [Hash] containing the guid: of the target node, optional
    #   * The global unique identifier (guid; 40 character hex string) of the node to get the profile data from
    #   * If the guid is omitted, your own node’s social accounts will be returned
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-profile
    # @return [Hash]
    def social_accounts(profile = nil); JSON[Api::get_profile(profile, self)]['profile']['social_accounts']; end
    
    # Returns the listings of the user’s node, or that of a target node.
    #
    # @param listings [Hash] containing the guid: of the target node, optional
    #   * If the guid is omitted, the server will look for listings in your own node’s database.
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_listings
    # @return [Hash]
    def listings(listings = nil); JSON[Api::get_listings(listings, self)]; end
    
    # Finds the listings of the user’s node, or that of a target node.
    #
    # @param options [Hash] containing:
    #     * guid: of the target node, optional
    #         *If the guid is omitted, the server will look for listings in your own node’s database.
    #     * pattern: [String] search phrase
    # @return [Hash]
    def query_listings(options = {})
      pattern = options.delete(:pattern)
      all_listings = JSON[Api::get_listings(options, self)]
      listings = all_listings['listings']
      
      if !!pattern
        listings = listings.select do |listing|
          listing['contract_hash'] =~ pattern ||
          listing['category'] =~ pattern ||
          listing['title'] =~ pattern ||
          listing['price'].to_s =~ pattern ||
          listing['origin'] =~ pattern ||
          listing['currency_code'] =~ pattern ||
          listing['ships_to'].join =~ pattern
        end
      end
      
      unless listings === all_listings
        start = Time.now.to_i
        @cache_timestamp = if (start - (@cache_timestamp || 0)) > 300
          @contracts_cache = {}
          start
        else
          @cache_timestamp
        end
        @contracts_cache ||= {}
        (all_listings['listings'] - listings).each do |listing|
          contract_hash = listing['contract_hash']
          contract = @contracts_cache[contract_hash] ||= contracts(options.merge(id: listing['contract_hash']))
          next unless !!contract
          
          contract_listing = contract['vendor_offer']['listing']
          
          if contract_listing['metadata']['expiry'] =~ pattern ||
            contract_listing['item']['category'] =~ pattern ||
            contract_listing['item']['sku'] =~ pattern ||
            contract_listing['item']['description'] =~ pattern ||
            contract_listing['item']['process_time'] =~ pattern ||
            contract_listing['item']['keywords'].join =~ pattern
            listings << listing && next
          end
        end
      end
      
      {'listings' => listings}
    end
    
    # Returns the followers of the user’s node, or that of a target node.
    #
    # @param followers [Hash] containing the guid: of the target node, optional
    #   * If the guid is omitted, the server will look for followers in your own node’s database.
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_followers
    # @return [Hash]
    def followers(followers = nil); JSON[Api::get_followers(followers, self)]; end
    
    # Returns the following of the user’s node, or that of a target node.
    #
    # @param following [Hash] containing the guid: of the target node, optional
    #   * If the guid is omitted, the server will look for following in your own node’s database.
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_following
    # @return [Hash]
    def following(following = nil); JSON[Api::get_following(following, self)]; end
    
    # Follows a target node and will cause you to receive notifications from
    # that node after certain event (e.g. new listing, broadcast messages) and
    # share some metadata (in future).
    #
    # @param follow [Hash] containing the guid: of the target node, required
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-follow
    # @return [Hash] containing: "success" => true or false
    def follow(follow); JSON[Api::post_follow(follow, self)]; end
    
    # Stop following a target node, will cease to receive notifications and
    # sharing metadata.
    #
    # @param unfollow [Hash] containing the guid: of the target node, required
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-unfollow
    # @return [Hash] containing: "success" => true or false
    def unfollow(unfollow); JSON[Api::post_unfollow(unfollow, self)]; end
    
    # Add data related to the node's profile into the database, which will be
    # visible to other nodes.
    #
    # @param profile [Hash]
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-profile
    # @return [Hash] containing: "success" => true or false
    def update_profile(profile = {}); JSON[Api::post_profile(profile, self)]; end
    
    # Adds a social account to the user profile data of the user.
    #
    # @param social_account [Hash] e.g.: account_type: 'TWITTER', username: '@inertia186'
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-social_accounts
    # @return [Hash] containing: "success" => true or false
    def add_social_account(social_account = {}); JSON[Api::post_social_accounts(social_account, self)]; end
    
    # Undocumented.
    #
    # @return [Hash]
    def delete_social_account(social_account = {}); JSON[Api::delete_social_accounts(social_account, self)]; end
    
    # Retrieves the listings created by either your node or a target node.
    #
    # @param contracts [Hash] containing the:
    #   * id: Unique identifier of the contract SHA256 of the JSON formatted contract (40 character hex string), required
    #   * guid: GUID of the node if the call is made to a target node.  If omitted, the API will search for a contract ID created by your own node
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-contracts
    # @return [Hash]
    def contracts(contracts = {}); JSON[Api::get_contracts(contracts, self)]; end
    
    # Creates a listing contract, which is saved to the database and local file
    # system, as well as publish the keywords in the distributed hash table.
    #
    # @param contract [Hash] containing:
    #    * expiration_date: [UTC] Formatted string.  The date the contract should expire in string formatted UTC datetime.  Example:
    #        * "2015-11-01T00:00 UTC"
    #        * "" if the contract never expires
    #    * metadata_category: [category] Formatted string.  Select from:
    #        * physical good
    #        * digital good
    #        * service
    #    * title: [title text] String.  Title of the product for sale
    #    * description: [description text] String.  Description of the item, content or service
    #    * currency_code: [code] Formatted string.  The currency the product is priced in. may either be “btc” or a currency from this list
    #    * price: [value] String.  The price per unit in the same currency as currency_code.
    #    * process_time: [time] String.  The time it will take to prepare the item for shipping
    #    * nsfw: [true/false] Boolean.  Is the item not suitable for work (i.e. 18+)
    #    * shipping_origin: [country/region] Formatted string.  Required and only applicable if the metadata_category is a physical good
    #        * Where the item ships from
    #        * Must be a formatted string from this list
    #    * shipping_regions: [locations] Formatted string.  Required and only applicable if the metadata_category is a physical good.
    #        * A list of countries/regions where the product will ship to
    #        * Each item in the list must be formatted from this list
    #    * est_delivery_domestic: [time] Estimated delivery time for domestic shipments
    #    * est_delivery_international: [time] String.  Estimated delivery time for international shipments.
    #    * terms_conditions: [terms and conditions text] String.  Any terms or conditions the user wishes to include.
    #    * returns: [returns policy text] String.  Return policy.
    #    * shipping_currency_code: [currency code] Formatted string.  The currency code used to price shipping. may either be “btc” or a currency from this list.
    #    * shipping_domestic: [price] String.  The price of domestic shipping in the selected currency code.
    #    * shipping_international: [price] String.  The price of nternational shipping in the selected currency code.
    #    * keywords: [keyword text] String.  A list of string search terms for the listing.  Must be fewer than 10.
    #    * category: [category text] Sting.  A user-generated category for this product.  Will show in store’s category list.
    #    * condition: [condition text] The condition of the product
    #    * sku: [sku text] String.  Stock keeping unit (sku) for the listing.
    #    * images: [String, Array<String>] 40 character hex string.  A list of SHA256 image hashes.  The images should be uploaded using the upload_image api call.
    #        * images: '04192728d0fd8dfe6663f429a5c03a7faf907930'
    #        * images: ['04192728d0fd8dfe6663f429a5c03a7faf907930', '0dee4786fd02d6bc673b50309a3c831acf78ec70']
    #    * image_urls: [Array<String>] An image URL for OBarc to first download then automatically store to this record.
    #        * image_urls: 'http://i.imgur.com/YHBh57j.gif'
    #        * image_urls: ['http://i.imgur.com/uC2KUQ6.png', 'http://i.imgur.com/RliU8Gn.jpg']
    #    * free_shipping: [boolean] "true" or "false"
    #    * moderators: [guids] GUID: 40 character hex string.  A list of moderator GUIDs that the vendor wishes to use
    #        * Note: the moderator must have been previously returned by the get_moderators websocket call.
    #        * Given the UI workflow, this call should always be made before the contract is set.
    #    * options: [options text] String.  A list of options for the product.  Example: “size”, “color”
    #        * option: [option text] String.
    #            * For each option in the options list, another argument should be added using that option name and a list of value
    #            * For example, given “color” in the options list, choose from "red", "green", "purple" etc
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-contracts
    # @return [Hash] containing: "success" => true or false, "id" => Integer
    def create_contract(contract = {})
      # Note, passing contract_id appears to create a clone that re-uses the
      # original contract_id.
      
      if !!contract[:image_urls] && contract[:image_urls].any?
        urls = contract.delete(:image_urls)
        hashes = []
        
        urls.each do |url|
          response = upload_image(image: open(url, 'rb'))
          hashes += response['image_hashes'] if response['success']
        end
        
        contract[:images] = hashes
      end
      
      JSON[Api::post_contract(contract, self)]
    end
    
    # Undocumented.
    #
    # @return [Hash]
    def delete_contract(contract = {}); JSON[Api::delete_contract(contract, self)]; end
    
    # Sets your node as a Moderator, which is discoverable on the network.
    #
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-make_moderator
    # @return [Hash] containing: "success" => true or false
    def make_moderator; JSON[Api::post_make_moderator(self)]; end
    
    # Removes the node as a Moderator and is no longer discoverable on the
    # network as a Moderator.
    #
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post--unmake_moderator
    # @return [Hash] containing: "success" => true or false
    def unmake_moderator; JSON[Api::post_unmake_moderator(self)]; end
    
    # Purchases a contract by sending the purchase into the Vendor. The Buyer
    # waits for a response to indicate whether the purchase is successful or
    # not. If successful, the Buyer needs to fund the direct or multisig
    # address.
    #
    # @param purchase_contract [Hash]
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-purchase_contract
    # @return [Hash] containing:
    #   * "success" => true or false
    #   * "address" => "bitcoin address to fund"
    #   * "amount" => "amount to fund"
    #   * "order_id" => "purchase order id"
    def purchase_contract(purchase_contract = {}); JSON[Api::post_purchase_contract(purchase_contract, self)]; end
    
    # Sends the order confirmation and shipping information to the Buyer. If
    # he’s offline, it will embed this data into the dht. The API call also
    # updates the status of the order in the database.
    #
    # @param confirm_order [Hash]
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-confirm_order
    # @return [Hash] containing: "success" => true or false
    def confirm_order(confirm_order = {}); JSON[Api::post_confirm_order(confirm_order, self)]; end
    
    # Saves the image in the file system and a pointer to it in the db.
    # 
    # @param image [Hash] containing: 
    #     * image: a list of product images to upload (LIST of images in base64. data only, no base64 prefix)
    #     * avatar: use this if uploading an avatar image (base64 image)
    #     * header: use this if uploading a header image (base64 image)
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-upload_image
    # @return [Hash] containing:
    #    * "success" => true or false
    #    * "image_hashes" => [list_of_image_hashes]
    def upload_image(image = {}); JSON[Api::post_upload_image(image.merge(cookies: cookies, base_url: base_url))]; end
    
    # Sends a message with a partially signed transaction releasing funds from
    # escrow to the Vendor as well as review data.
    #
    # @param complete_order [Hash]
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-complete_order
    # @return [Hash] containing: "success" => true or false
    def complete_order(complete_order = {}); JSON[Api::post_complete_order(complete_order, self)]; end
    
    # Changes the settings of the node and pushes them to the database.
    #
    # @param settings [Hash]
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-settings
    # @return [Hash] containing: "success" => true or false
    def update_settings(settings = {}); JSON[Api::post_settings(settings, self)]; end
    
    # Returns the settings of your node.
    #
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-settings
    # @return [Hash]
    def settings; JSON[Api::get_settings(self)]; end
    def connected_peers; JSON[Api::get_connected_peers(self)]; end
    
    # Retreive a history of all notifications your node has received. Notifications can be sent due to:
    # * A node following you
    # * Events related to a purchase or sale
    #
    # @param FIXME not yet supported, future: limit-[number of most recent notifications]
    #   * Default is unlimited
    #   * Counts from most recent
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-notifications
    # @return [Hash]
    def notifications; JSON[Api::get_notifications(self)]; end
    
    # Marks a notification as read in the database.
    #
    # @param notification [Hash] containing id:
    #     * 40 character hex string
    #     * Every notification has an ID that must be referenced in order to mark as read
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-mark_notification_as_read
    # @return [Hash] containing: "success" => true or false
    def mark_notification_as_read(notification = nil); JSON[Api::post_mark_notification_as_read(notification, self)]; end
    
    # Sends some kind of "Twitter-like" message to all nodes that are following
    # you.  This call can take a while to complete.
    #
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-broadcast
    # @return [Hash] containing:
    #    * "success" => true or false
    #    * "peers_reached" => [number reached]
    def broadcast(message = {}); JSON[Api::post_broadcast(message, self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def btc_price; JSON[Api::get_btc_price(self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def routing_table; JSON[Api::get_routing_table(self)]; end
    
    # API call to cleanly disconnect from connected nodes and shutsdown the OpenBazaar server component.
    #
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-shutdown
    # @return nil
    def shutdown!
      begin
        Api::get_shutdown(self)
      rescue Errno::ECONNREFUSED => e
        # TODO Add logging.
      end
    end
  end
end
