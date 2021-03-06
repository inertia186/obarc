require 'obarc/api'
require 'open-uri'
require 'logging'

module OBarc
  class Session
    OPTIONS_KEYS = %i(protocol server_host server_port api_version username
      password base_url logger cookies verify_ssl)
    
    attr_accessor :cookies, :username, :password, :verify_ssl
    attr_writer :base_url, :logger
    
    DEFAULT_OPTIONS = {
      protocol: 'http',
      server_host: 'localhost',
      server_port: '18469',
      api_version: 'v1',
      verify_ssl: true
    }
    
    def initialize(options = {})
      OPTIONS_KEYS.each do |k|
        value = if options.key?(k)
          options[k]
        else
          DEFAULT_OPTIONS[k]
        end
        
        instance_variable_set "@#{k}".to_sym, value
      end
      
      @base_url ||= base_url
      @logger ||= logger
      @cookies ||= Api::post_login(self).cookies
    end
    
    def base_url
      @base_url ||= "#{@protocol}://#{@server_host}:#{@server_port}/api/#{@api_version}"
    end
    
    def logger
      @logger ||= Logging.logger(STDOUT)
    end
    
    # Check if there's a valid session.
    #
    # @return [Boolean] True if the session is valid.
    def ping
      return false if !(json = Api::ping(self))
      !!JSON[json]['num_peers']
    rescue RestClient::Unauthorized => e
      logger.warn(e)
      false
    end
    
    # Returns the image for the hash specified.
    # @param image [Hash] containing the hash: of the target image, required
    # @return [Object] The image will be returned in .jpg format.
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-image
    def image(image); Api::get_image(image, self); end
    
    # Returns the profile data of the user’s node, or that of a target node.
    #
    # @param profile [Hash] containing the guid: of the target node, optional
    #   * The global unique identifier (guid; 40 character hex string) of the node to get the profile data from
    #   * If the guid is omitted, your own node’s profile will be returned
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-profile
    def profile(profile = nil); JSON[Api::get_profile(profile, self)]; end
    
    # Returns just the profile's social accounts of the user’s node, or that of a target node.
    #
    # @param profile [Hash] containing the guid: of the target node, optional
    #   * The global unique identifier (guid; 40 character hex string) of the node to get the profile data from
    #   * If the guid is omitted, your own node’s social accounts will be returned
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-profile
    def social_accounts(profile = nil)
      result = JSON[Api::get_profile(profile, self)]
      
      if !!result && !!result['profile'] && !!result['profile']['social_accounts']
        result['profile']['social_accounts']
      else
        []
      end
    end
    
    # Returns the listings of the user’s node, or that of a target node.
    #
    # @param listings [Hash] containing the guid: of the target node, optional
    #   * If the guid is omitted, the server will look for listings in your own node’s database.
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_listings
    def listings(listings = nil); JSON[Api::get_listings(listings, self)]; end
    
    # Finds the listings of the user’s node, or that of a target node.
    #
    # @param options [Hash] containing:
    #     * guid: of the target node, optional
    #         *If the guid is omitted, the server will look for listings in your own node’s database.
    #     * pattern: [Regex] search phrase
    # @return [Hash]
    def query_listings(options = {})
      pattern = options.delete(:pattern)
      all_listings = JSON[Api::get_listings(options, self)]
      listings = all_listings['listings']
      
      if !!pattern
        listings = listings.select do |l|
          [l['contract_hash'], l['category'], l['title'],
            l['price'].to_s, l['origin'], l['currency_code'],
            l['ships_to'].join].join(' ') =~ pattern
        end
      end
      
      return {'listings' => listings} if listings === all_listings
      
      start = Time.now.to_i
      
      @cache_timestamp = if (start - (@cache_timestamp ||= 0)) > 300
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
        
        l = contract['vendor_offer']['listing']
        
        if [l['metadata']['expiry'], l['item']['category'], l['item']['sku'],
          l['item']['description'], l['item']['process_time'],
          l['item']['keywords'].join].join(' ') =~ pattern
          listings << listing && next
        end
      end
    
      {'listings' => listings}
    end
    
    # Returns the followers of the user’s node, or that of a target node.
    #
    # @param followers [Hash] containing the guid: of the target node, optional
    #   * If the guid is omitted, the server will look for followers in your own node’s database.
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_followers
    def followers(followers = nil); JSON[Api::get_followers(followers, self)]; end
    
    # Returns the following of the user’s node, or that of a target node.
    #
    # @param following [Hash] containing the guid: of the target node, optional
    #   * If the guid is omitted, the server will look for following in your own node’s database.
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_following
    def following(following = nil); JSON[Api::get_following(following, self)]; end
    
    # Follows a target node and will cause you to receive notifications from
    # that node after certain event (e.g. new listing, broadcast messages) and
    # share some metadata (in future).
    #
    # @param follow [Hash] containing the guid: of the target node, required
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-follow
    def follow(follow); JSON[Api::post_follow(follow, self)]; end
    
    # Stop following a target node, will cease to receive notifications and
    # sharing metadata.
    #
    # @param unfollow [Hash] containing the guid: of the target node, required
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-unfollow
    def unfollow(unfollow); JSON[Api::post_unfollow(unfollow, self)]; end
    
    # Add data related to the node's profile into the database, which will be
    # visible to other nodes.
    #
    # @param profile [Hash]
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-profile
    def update_profile(profile = {}); JSON[Api::post_profile(profile, self)]; end
    
    # Adds a social account to the user profile data of the user.
    #
    # @param social_account [Hash] e.g.: account_type: 'TWITTER', username: '@inertia186'
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-social_accounts
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
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-contracts
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
    #    * image_urls: [Array<String>] An array of image URLs for OBarc to first download then automatically store to this record.
    #        * image_urls: 'http://i.imgur.com/YHBh57j.gif'
    #        * image_urls: ['http://i.imgur.com/uC2KUQ6.png', 'http://i.imgur.com/RliU8Gn.jpg']
    #    * image_data: [Array<String>] An array of Base64 images for OBarc to automatically store to this record.
    #        * image_data: <String>
    #        * image_data: [<String>, <String>]
    #    * free_shipping: [boolean] "true" or "false"
    #    * moderators: [guids] GUID: 40 character hex string.  A list of moderator GUIDs that the vendor wishes to use
    #        * Note: the moderator must have been previously returned by the get_moderators websocket call.
    #        * Given the UI workflow, this call should always be made before the contract is set.
    #    * options: [options text] String.  A list of options for the product.  Example: “size”, “color”
    #        * option: [option text] String.
    #            * For each option in the options list, another argument should be added using that option name and a list of value
    #            * For example, given “color” in the options list, choose from "red", "green", "purple" etc
    # @return [Hash] containing: "success" => true or false, "id" => Integer
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-contracts
    def create_contract(contract = {})
      # Note, passing contract_id appears to create a clone that re-uses the
      # original contract_id.
      
      %i(image_urls image_data).each do |symbol|
        upload_contract_images_with(symbol, contract) if !!contract[symbol]
      end
      
      JSON[Api::post_contract(contract, self)]
    end

    def upload_contract_images_with(symbol, contract = {})
      contract[:images] = [contract.delete(symbol)].flatten.map do |image|
        response = if image.size < 2000 && image =~ URI::ABS_URI
          upload_image(image: open(image, 'rb'))
        else
          upload_image(image: image)
        end
                 
        response['image_hashes'] if response['success']
      end.flatten
    end
    
    # Undocumented.
    #
    # @return [Hash]
    def delete_contract(contract = {}); JSON[Api::delete_contract(contract, self)]; end
    
    # Sets your node as a Moderator, which is discoverable on the network.
    #
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-make_moderator
    def make_moderator; JSON[Api::post_make_moderator(self)]; end
    
    # Removes the node as a Moderator and is no longer discoverable on the
    # network as a Moderator.
    #
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post--unmake_moderator
    def unmake_moderator; JSON[Api::post_unmake_moderator(self)]; end
    
    # Purchases a contract by sending the purchase into the Vendor. The Buyer
    # waits for a response to indicate whether the purchase is successful or
    # not. If successful, the Buyer needs to fund the direct or multisig
    # address.
    #
    # @param purchase_contract [Hash]
    # @return [Hash] containing:
    #   * "success" => true or false
    #   * "address" => "bitcoin address to fund"
    #   * "amount" => "amount to fund"
    #   * "order_id" => "purchase order id"
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-purchase_contract
    def purchase_contract(purchase_contract = {}); JSON[Api::post_purchase_contract(purchase_contract, self)]; end
    
    # Sends the order confirmation and shipping information to the Buyer. If
    # he’s offline, it will embed this data into the dht. The API call also
    # updates the status of the order in the database.
    #
    # @param confirm_order [Hash]
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-confirm_order
    def confirm_order(confirm_order = {}); JSON[Api::post_confirm_order(confirm_order, self)]; end
    
    # Saves the image in the file system and a pointer to it in the db.
    # 
    # @param image [Hash] containing: 
    #     * image: a list of product images to upload (LIST of images in base64. data only, no base64 prefix)
    #     * avatar: use this if uploading an avatar image (base64 image)
    #     * header: use this if uploading a header image (base64 image)
    # @return [Hash] containing:
    #    * "success" => true or false
    #    * "image_hashes" => [list_of_image_hashes]
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-upload_image
    def upload_image(image = {}); JSON[Api::post_upload_image(image.merge(cookies: cookies, base_url: base_url, verify_ssl: verify_ssl))]; end
    
    # Sends a message with a partially signed transaction releasing funds from
    # escrow to the Vendor as well as review data.
    #
    # @param complete_order [Hash]
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-complete_order
    def complete_order(complete_order = {}); JSON[Api::post_complete_order(complete_order, self)]; end
    
    # Changes the settings of the node and pushes them to the database.
    #
    # @param settings [Hash]
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-settings
    def update_settings(settings = {}); JSON[Api::post_settings(settings, self)]; end
    
    # Returns the settings of your node.
    #
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-settings
    def settings; JSON[Api::get_settings(self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def connected_peers; JSON[Api::get_connected_peers(self)]; end
    
    # Retreive a history of all notifications your node has received. Notifications can be sent due to:
    # * A node following you
    # * Events related to a purchase or sale
    #
    # @param FIXME not yet supported, future: limit-[number of most recent notifications]
    #   * Default is unlimited
    #   * Counts from most recent
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-notifications
    def notifications; JSON[Api::get_notifications(self)]; end
    
    # Retrieves all chat message received from other nodes.
    #
    # @param chat_messages [Hash] containing:
    #   * guid [String] target node, required
    #   * limit [Integer] max number of chat messages to return (ignored)
    #   * start [FIXME] the starting point in the message list
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_chat_messages
    def chat_messages(chat_messages = {}); JSON[Api::get_chat_messages(chat_messages, self)]; end
    
    # Retreives a list of outstandng conversations.
    #
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_chat_conversations
    def chat_conversations; JSON[Api::get_chat_conversations(self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def delete_chat_conversation(delete_chat_conversation); JSON[Api::delete_chat_conversation(delete_chat_conversation, self)]; end
    
    # Retrieves any sales made by the node.
    #
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_sales
    def sales; JSON[Api::get_sales(self)]; end
    
    # Retrieves any purchases made by the node.
    #
    # @return [Hash]
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-get_purchases
    def purchases; JSON[Api::get_purchases(self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def order(order); JSON[Api::get_order(order, self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def cases; JSON[Api::get_cases(self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def order_messages(order_messages); JSON[Api::get_order_messages(order_messages, self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def ratings(ratings); JSON[Api::get_ratings(ratings, self)]; end
    
    # Marks a notification as read in the database.
    #
    # @param notification [Hash] containing id:
    #     * 40 character hex string
    #     * Every notification has an ID that must be referenced in order to mark as read
    # @return [Hash] containing: "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-mark_notification_as_read
    def mark_notification_as_read(notification = nil); JSON[Api::post_mark_notification_as_read(notification, self)]; end
    
    # Sends some kind of "Twitter-like" message to all nodes that are following
    # you.  This call can take a while to complete.
    #
    # @return [Hash] containing:
    #    * "success" => true or false
    #    * "peers_reached" => [number reached]
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-broadcast
    def broadcast(message = {}); JSON[Api::post_broadcast(message, self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def btc_price; JSON[Api::get_btc_price(self)]; end
    
    # Undocumented
    #
    # @return [Hash]
    def routing_table; JSON[Api::get_routing_table(self)]; end
    
    # Marks all chat messages with a specific node as read in the database.
    #
    # @param chat_message_as_read [Hash] containing:
    #   * guid [String] GUID of the party you are chatting with
    # @return [Hash] containing:
    #    * "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-mark_chat_message_as_read
    def mark_chat_message_as_read(mark_chat_message_as_read = nil); JSON[Api::post_mark_chat_message_as_read(mark_chat_message_as_read, self)]; end
    
    # Sends a Twitter-like message to all nodes that are following you.
    #
    # @param check_for_payment [Hash] containing:
    #   * order_id [Integer]
    # @return [Hash] containing:
    #    * "success" => true or false
    # @see https://gist.github.com/drwasho/bd4b28a5a07c5a952e2f#post-check_for_payment
    def check_for_payment(check_for_payment); JSON[Api::post_check_for_payment(check_for_payment, self)]; end
    
    # Undocumented
    #
    # @param dispute_contract [Hash] containing:
    #   * order_id [Integer]
    # @return [Hash] 
    def dispute_contract(dispute_contract = nil); JSON[Api::post_dispute_contract(dispute_contract, self)]; end
    
    # Undocumented
    #
    # @param dispute_contract [Hash] containing:
    #   * order_id [Integer]
    #   * resolution [String]
    #   * buyer_percentage [Float]
    #   * vendor_percentage [Float]
    #   * moderator_percentage [Float]
    #   * moderator_address [String]
    # @return [Hash] 
    def close_dispute(close_dispute = nil); JSON[Api::post_close_dispute(close_dispute, self)]; end
    
    # Undocumented
    #
    # @return [Hash] 
    def release_funds(release_funds = nil); JSON[Api::post_release_funds(release_funds, self)]; end
    
    # Undocumented
    #
    # @return [Hash] 
    def refund(refund = nil); JSON[Api::post_refund(refund, self)]; end
    
    # Undocumented
    #
    # @return [Hash] 
    def mark_discussion_as_read(mark_discussion_as_read = nil); JSON[Api::post_mark_discussion_as_read(mark_discussion_as_read, self)]; end
    
    # API call to cleanly disconnect from connected nodes and shutsdown the OpenBazaar server component.
    #
    # @return nil
    # @see https://gist.github.com/drwasho/742505589f62f6aa98b4#get-shutdown
    def shutdown!
      Api::get_shutdown(self)
    end
  end
end
