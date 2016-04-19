require 'test_helper'

module OBarc
  class SessionTest < OBarc::Test
    SPAM_IMAGE = 'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAC91JREFUWAktl3mQHOV5xn99zH3u7K1d7Uq7CEkIpNVZRhagQDjKCcaxSIJNIJTjI5XCuakKceXyHy5XnJSr+IM4VCVOynZiEuwq48J/mMiVBMck2AoBgYQutKu9d2Z2zp6ZnunpztMjpqp3u7/++vve43me9/2MQD/0a1TLVMsbVCtlWk6bZCTANHya7T5+4GNqTj+cqivAxzL01/f1GGDoXTga3vv9cE44Ho6BoZeWaRBNZEikc2TyefKFCfLD43qr90HgB99/8eu89u3fYHgYblwGrwu/8OgcueFZqo0+fW2EEcH3evqgrvWrxGwfTxN9v6TNfP0HtwW9HjIYuh096+pqbGYe9i3cz8q1V7l6CZZW4J4nXuCXHv8MxvL1K8ETu/dw5gu/rI169OVZIplkdmqSVtulUVslHrVJ5yaI2B5O02NoaAinXtF8A8u25aklYzz6PZeW61OrtRgZydDz7UEE8rkUU+NJRbdKqVjnxtI6P3ru3/jq2+ewS+vXOfGrCcyIzY6JISKJYZzGtsKVotYO6Hpp3HYHz13HcRxKNZ/J2QSzcwtE9U3ENgi8NnYkSlyGt1sdKs0+6WR0kMIkfbyyS6XUx7AKzOyNYSRv8LEvQHH5AvaufUc4dPK3sI1txkeGSSYT9EemZVCEsdEh7OgcpXJT4feIxUwqVRen7VHIy/Mw7sKDL4DIVDptpUgRjClSXddR7gNKjnIgHHjdJraQ1O1kGBp8u8DehdMYtZoT3PPIl3ho/wW2nRSpuBJo2HgKb1R5lnsD70zTpOcF8hilxKDZdAfgdHtKgxXiTp562qgfPhvyPtB8fa97LwSmjHC6BpMpl07H52vfyrO6+hWtbXmcnN9U2Cu88E2tQFtXnfuOtjh7Lq778BfiPE40FnrWH4zc/OOza8xlcUtWCQc3cR++CeeHY+F6IX8GfND/KA99GLL5qO5TA9bYlm1x6qjJT1/3OXY8xRd/c5OxoS3W19J85dkV/vdCgf3zjQFDSpUMyXiLdifCs1+d4e6jDk8//jPOX57n/k/t4qmPd/jdJy8r/y7vXZ/iFz83zV89U+The6/Qdg3+5l+OsLKeImIqLTvTSpGF6Qcx3lw5TrEMj3+kyd3H36BUKfDw07fw47fmldMobi/C5Ogyf/viDD+7MMnRO67wx59b5f5TRRqtDAf3XeP3n3L5h+9m6fZiZDN1jS3zoSMBJ4+WGS049PtJvvOfFiMFUdOPMSJmGEqr4uOztlHDisf0saELFm67xLWzr3Ps9m0ur2QwbRPXS3LqWJMTB4vUm2nyOTGjH+f5bx8WOOGBu6oKq0GnF+Xa8jSxuMWX/3BFLApkpF6ZcUorQ4RYCowUE9n44N60lYLZ2R3ksgZ/9/0M//zKadaLUwPrbp1b5tOPXiSV6MiDDAv7K2wUs3zx+Q/RcLJMT9T56H1lqeUQt85tMrc7zHmUNy9OCcQJbtuzxVvv7ZBWhDkPscCAtn3RpphQCrS3OZBMYWSjkuAvPltkZofL4Y8u8CfPLUhoEkJyWpbaZFKbvHx2koc+tZuLS1HmZso8/0/7+O0vz3F9ZYodY0We/UydTNpleSPByuYwi6s7eOdqRmPdQZRCIxQA2l6M35vZJC262obEui31ymfhhz/J8/lPrvLfL10NecXyWowf/Psodx1vsrh2iPlZVz54fOx0BadlUq6ZnD8fUK4q7Ddu47Zb2qJmTP9dHntmno26wV8/vc1GeVYRifLYI10arsWkNn7gnlmFQ6LkiaTP/NlL9Lf+ledetpmfm+J3Ht090PcbxRATAVvFEp6VYud4jkqlRCqdxo6lWFtdYffspNSxxdefOyvjQopGdIU/0TJnMZf3eH9JIU7L9WaUz36iQdec4fN/8BQHDhwekFWgMGWhyclbItRaZf7075tUr/QY39/n9rEo+yW9+3cHFLImmfkYSVsb9as4sxHalTUBr8apP5pls+XTWqtT9kyuyvtXf9Tk/VqoCSZjGTnSNAfYcj2bcrEyQMUgBalUnL4VUUh9Lr3j8ImPj3Hvr+9iSrVhSGjNRXzi0vwwgX6zMdCZQGXPjCRgSOPBmMQzSr/p4B8awVc98HJ5Smdcrr29zoX1Di+uyuh1fSpnTe2VVK0I9SpcVgxIsO4IfPsn+dqX7mJ6NEO0L/33PXpddyClrrTdUL31Ox2CjOgUarLKceCoCoaSq7prZrMEKmRqI4j2+uxMwY7JgA/PpTnTNXlprM22V6OrjJSrN1VyUC9rWmTnznGePPMg0WgG16krrGE+QxGNqAdwFToBpt+RXmTot3oDjBgtRUMFwAy1PmwEnKbmKvfJGH6vjVfsiEXGYCyvmvDpB0d4b9vhzPdc9vxfnYc/YocsgGrL4+f2HiGrElwpFQcCYcnDQB726mWFvTkQKsOTotQV+qCH31DXEsYwmxx0H0Gg+S2NtesyROFVCScnsErxAtNXn6H8q9+YTqkTallE4wJrmILQy9nJDDPjZbqNNSxXHY+c9+tFAVqL12uaIamrOwQ9LSpN8CttRcAadEH989cxCwW8+ubNcqQqaKQzWlurd0TLir6Pq99IqKOipwob48G8MKeKqxk3DTClpe12E1PJCaTFQVueSqEMeWq4arsqTXmpEAtkXjRFr7iNJ28teag1MTZK2GEkMnre3ta38iDEiDITGmOaeg6EF20ZlRMT2Zx6CNFSFig4MtBpYP70Eu0led0UiHAH3QwVPcciBFub+F3Ve1dtR6mCq7bMUyTcje1BT+C7ApRCrsqPnZBnAq7qO1ZbV1ptiOoMoez2fVYrBv9YjJCKhOVbw1qXecnnqLjdeuUK8V+5l35OsljaILBEu3qLIDsqg0IOe+pN1REHbfrawxrO4jlKi5oTS4Z6a1WFOqbxYfy0aGmrW2yITYtbSpHmqcOOjY9za1yR0PwwBLYKHXsOSoDe2MZKKa9XVzHv2gd3HNAmDfrFVTpLS7RKVaKHDym66geKRfxqnVhY0YTuWCaJqU0DW7pgRjB7omRI0Y0tjJUNzJLYozauL8lP7IHJgljyQXGyQ85eaw9jHdtD/+W3mLbeJn3xLbqJEVA4qUmxBDRrqU5rXOCaHsdRL7its8P7XUVkLKWqOExC4S0oEnn1j/lijYSAauUU+t1DqIGkOxrDSalRnchyOsSO8UEKwn7uf961ODw5Q+2+TWo/bjA3bVIYlveL4vlah5Jo05Yq+l213OcWWVHUttIxSXuU9voG66/dYFhaMlSIMinxKhydIXn/7VgCbrfkERXq7ahPfU3p2GGTKNhiw82aMaBhImFhN232Hj/E6+Yir716jU+enCF7cJY3vvmueJomlYmTTsRJiRUTCmdPi1dr6nwn8sQlJuH5IJGJETm8QHx0Sp11TnIQ5cbiOrfuGMFdXaIyeZ2ZA7Nc/G7AnacVnRCEbsfhRq3DjDh7ZE+ByLE0U0mPC1sm9nqZc7UIu5TnZMdjeCSixUVDR2X1eplAitfp+WTGchRmx7D9NqXxKWb23068XFK9qnNAEU4lcyyfuJuEN0Jh8Qbn3rQ4drf4KyRYT/7aY3/+xDeKHIyscmx0XaEZZXR8N8N9j5yUa/TOndiCfK2Q4L2Gh78upOtd2HqnxePMuOqCCku50eBqo80rPznPO2rH3g86XBOl64ruBfUWdmuNuaV3Wbl0hb9s3YHl1Pj5g1m15aLfC6eWuHi9xHdeXuWBI9ogP67j1yT90THGOk1ip4dpq+//r3KVt1drLJ5d4qAMCg3pVFtUROXvNXvsPzrNE3fq9JOsSeMrBJrT2lqh8O4y6VabK5sW/5GqcDRW55G9KiN9CZ2OW8HlC6+rhC6xUnRIOtsMB01UQwaFx0ikMKOillpor1piTei9UuwyJJpZQ0kqqu2VUkMlIUpOODkxJhwIE143rAvSBzU0OD0cHUbeaNtMz+l0nC+QHZ5n74ETUlv9ljaadJqrKhKbOuG2dAzXOU4VLhC1wuPXoG8Mq5YuEUBc1zFc9zeP53rUvTKi1x+cgkLR1b1e6L8ETKoXtuBRjdvqIdzoqBgzzU5R8v8BFk2UYTA0hlwAAAAASUVORK5CYII='
    AVATAR_IMAGE = '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'

    def setup
      stub_post_login
      @session = OBarc::Session.new(username: 'username', password: 'password')
    end
    
    def test_method_missing
      begin
        @session.bogus
        fail 'did not expect missing method not to be missing'
      rescue NoMethodError => e
        # success
      end
    end

    def test_image
      stub_get_image(hash: '04192728d0fd8dfe6663f429a5c03a7faf907930')
      response = @session.image hash: '04192728d0fd8dfe6663f429a5c03a7faf907930'
      assert response, response
    end
    
    def test_image_wrong_hash
      stub_get_image(hash: 'WRONG')
      begin
        response = @session.image(hash: 'WRONG')
        fail 'Should be 404'
      rescue RestClient::ResourceNotFound => e
        # success
      end
    end
    
    def test_profile
      stub_get_profile
      response = @session.profile(guid: '2d48aef1b80affc7ba05d28d8e6b1001be023ba3')
      assert response['profile'], response
    end
    
    def test_profile_self
      stub_get_profile
      response = @session.profile
      assert response['profile'], response
    end
    
    def test_social_accounts
      stub_get_profile
      response = @session.social_accounts(guid: '2d48aef1b80affc7ba05d28d8e6b1001be023ba3')
      assert response.any?, response
    end
    
    def test_social_accounts_self
      stub_get_profile
      response = @session.social_accounts
      assert response.any?, response
    end
    
    def test_listings
      stub_get_listings
      response = @session.listings(guid: '2d48aef1b80affc7ba05d28d8e6b1001be023ba3')
      assert response['listings'], response
    end
    
    def test_listings_self
      stub_get_listings
      response = @session.listings
      assert response['listings'], response
    end
    
    def test_followers
      stub_get_followers
      response = @session.followers(guid: '2d48aef1b80affc7ba05d28d8e6b1001be023ba3')
      assert response['followers'], response
    end
    
    def test_followers_self
      stub_get_followers
      response = @session.followers
      assert response['followers'], response
    end
    
    def test_following
      stub_get_following
      response = @session.following(guid: '2d48aef1b80affc7ba05d28d8e6b1001be023ba3')
      assert response['following'], response
    end
    
    def test_following_self
      stub_get_following
      response = @session.following
      assert response['following'], response
    end
    
    def test_follow
      stub_post_generic_success as: :follow
      response = @session.follow(guid: '0dea93045d3beda948517a62aaab33a82213bd7b')
      assert response['success'], response
    end
    
    def test_unfollow
      stub_post_generic_success as: :unfollow
      response = @session.unfollow(guid: '0dea93045d3beda948517a62aaab33a82213bd7b')
      assert response['success'], response
    end
    
    def test_update_profile
      stub_post_upload_image
      stub_post_generic_success as: :profile
      response = @session.upload_image image: AVATAR_IMAGE
      avatar_hash = response['image_hashes'][0]
      response = @session.upload_image image: SPAM_IMAGE
      header_hash = response['image_hashes'][0]
      response = @session.update_profile(
        about: 'about',
        short_description: 'short_description',
        nsfw: 'false',
        vendor: 'true',
        moderator: 'false',
        moderation_fee: '0.00',
        website: 'website',
        email: 'email',
        primary_color: '16777215',
        secondary_color: '15132390',
        background_color: '12832757',
        text_color: '5526612',
        avatar: avatar_hash,
        header: header_hash,
        pgp_key: ''
      )
      assert response['success'], response
    end
    
    def test_update_profile_empty
      stub_post_generic_success as: :profile
      response = @session.update_profile {}
      assert response['success'], response
    end
    
    def test_add_social_account
      stub_post_generic_success as: :social_accounts
      response = @session.add_social_account(
        account_type: 'TWITTER',
        username: 'TWITTER',
        proof: nil
      )
      assert response['success'], response
    end
    
    def test_add_social_account_empty
      stub_post_generic_failure as: :social_accounts
      response = @session.add_social_account {}
      refute response['success'], response
    end
    
    def test_delete_social_account
      stub_delete_generic_success as: :social_accounts
      response = @session.delete_social_account(
        account_type: 'TWITTER',
      )
      assert response['success'], response
    end
    
    def test_delete_social_account_empty
      stub_delete_generic_failure as: :social_accounts
      response = @session.delete_social_account
      refute response['success'], response
    end
    
    def test_contracts
      stub_get_contracts
      response = @session.contracts(id: '3c7c653865952abd0a308300cdd8b770bf55d84a')
      assert response['vendor_offer'], response
    end
    
    def test_contracts_empty
      stub_get_contracts
      response = @session.contracts
      assert response['vendor_offer'], response
    end
    
    def test_contracts_wrong_guid
      stub_get_generic_empty_hash as: :contracts
      response = @session.contracts(id: '3c7c653865952abd0a308300cdd8b770bf55d84a', guid: '664b77de3ab547e13bcebca3cf296755b788fa74')
      refute response['vendor_offer'], response
    end
    
    def test_contracts_short_id
      stub_get_generic_empty_hash as: :contracts
      begin
        response = @session.contracts(id: '123')
        fail 'did not expect short id to work'
      rescue OBarc::Utils::Exceptions::OBarcError => e
        # success
      end
    end
    
    def test_contracts_short_guid
      stub_get_generic_empty_hash as: :contracts
      begin
        response = @session.contracts(guid: '123')
        fail 'did not expect short guid to work'
      rescue OBarc::Utils::Exceptions::OBarcError => e
        # success
      end
    end
    
    def test_add_contract
      stub_post_upload_image
      stub_post_generic_success as: :contracts
      response = @session.upload_image image: SPAM_IMAGE
      image_hashes = response['image_hashes']
      response = @session.add_contract(
        expiration_date: (Time.now + 30).utc.strftime('%Y-%m-%dT%H:%M'), # Format: 2016-04-19T11:50 or empty string
        metadata_category: 'metadata_category',
        title: 'title',
        description: 'description',
        currency_code: 'USD',
        price: '1.00',
        process_time: '3 Business Days',
        nsfw: false,
        # shipping_origin: 'shipping_origin',
        ships_to: 'ships_to',
        est_delivery_domestic: 'est_delivery_domestic',
        est_delivery_international: 'est_delivery_international',
        terms_conditions: 'terms_conditions',
        returns: 'returns',
        shipping_currency_code: 'shipping_currency_code',
        shipping_domestic: 'shipping_domestic',
        shipping_international: 'shipping_international',
        keywords: 'keyword1 keyword2',
        category: 'category',
        condition: 'New',
        sku: '736B75',
        images: image_hashes[0],
        free_shipping: true,
        # options: 'options',
        # moderators: 'moderators',
        # contract_id: 'contract_id'
      )
      assert response['success'], response
    end
    
    def test_add_contract_with_image_urls
      stub_post_upload_image
      stub_post_generic_success as: :contracts
      stub_request(:get, /imgur/).
        to_return(status: 200, body: fixture('04192728d0fd8dfe6663f429a5c03a7faf907930.jpg'), headers: {})
  
      response = @session.add_contract(
        expiration_date: (Time.now + 30).utc.strftime('%Y-%m-%dT%H:%M'), # Format: 2016-04-19T11:50 or empty string
        metadata_category: 'metadata_category',
        title: 'title',
        description: 'description',
        currency_code: 'USD',
        price: '1.00',
        process_time: '3 Business Days',
        nsfw: false,
        # shipping_origin: 'shipping_origin',
        ships_to: 'ships_to',
        est_delivery_domestic: 'est_delivery_domestic',
        est_delivery_international: 'est_delivery_international',
        terms_conditions: 'terms_conditions',
        returns: 'returns',
        shipping_currency_code: 'shipping_currency_code',
        shipping_domestic: 'shipping_domestic',
        shipping_international: 'shipping_international',
        keywords: 'keyword1 keyword2',
        category: 'category',
        condition: 'New',
        sku: '736B75',
        image_urls: [
          'http://i.imgur.com/uC2KUQ6.png',
          'http://i.imgur.com/RliU8Gn.jpg'
        ],
        free_shipping: true,
        # options: 'options',
        # moderators: 'moderators',
        # contract_id: 'contract_id'
      )
      assert response['success'], response
    end
    
    def test_add_contract_empty
      stub_post_generic_failure as: :contracts
      response = @session.add_contract
      refute response['success'], response
    end
    
    def test_delete_contract
      stub_delete_generic_success as: :contracts
      response = @session.delete_contract id: '0dee4786fd02d6bc673b50309a3c831acf78ec70'
      assert response['success'], response
    end
    
    def test_delete_contract_wrong
      stub_delete_generic_failure as: :contracts
      response = @session.delete_contract id: '99'
      refute response['success'], response
    end
    
    def test_shutdown
      stub_get_generic_nil_response as: :shutdown
      response = @session.shutdown!
      assert response.nil? || response.empty?, "did not expect response after shutdown, got: #{response}"
    end
    
    def test_make_moderator
      stub_post_generic_success as: :make_moderator
      response = @session.make_moderator
      assert response['success'], response
    end
    
    def test_unmake_moderator
      stub_post_generic_success as: :unmake_moderator
      response = @session.unmake_moderator
      assert response['success'], response
    end
    
    def test_purchase_contract
      stub_post_generic_success as: :purchase_contract
      response = @session.purchase_contract(
        id: '664b77de3ab547e13bcebca3cf296755b788fa74',
        quantity: '1',
        refund_address: 'mmqcyagCJgCKwSDZmRxLS8N9yUW4unM3Qs'
      )
      assert response['success'], response
    end
    
    def test_purchase_contract_empty
      stub_post_generic_failure as: :purchase_contract
      response = @session.purchase_contract {}
      refute response['success'], response
    end
    
    # TODO
    # def test_confirm_order
    #   response = @session.confirm_order(
    #     id: '',
    #     .
    #     .
    #     .
    #   )
    #   assert response['success'], response
    # end
    
    def test_confirm_order_empty
      stub_post_generic_failure as: :confirm_order
      response = @session.confirm_order {}
      refute response['success'], response
    end
    
    def test_upload_image_image
      stub_post_upload_image
      response = @session.upload_image image: AVATAR_IMAGE
      assert response['success'], response
      refute response['image_hashes'].empty?, response
    end
    
    def test_upload_image_avatar
      stub_post_upload_image
      response = @session.upload_image avatar: AVATAR_IMAGE
      assert response['success'], response
      refute response['image_hashes'].empty?, response
    end
    
    def test_upload_image_header
      stub_post_upload_image
      response = @session.upload_image header: AVATAR_IMAGE
      assert response['success'], response
      refute response['image_hashes'].empty?, response
    end
    
    def test_upload_image_empty
      stub_post_upload_image_empty as: :upload_image # Weird corner case?
      response = @session.upload_image
      assert response['success'], response
      assert response['image_hashes'].empty?, response
    end
    
    # TODO
    # def test_complete_order
    #   response = @session.complete_order(
    #     id: 'id',
    #     feedback: 'feedback',
    #     qulity: 'quality',
    #     description: 'description',
    #     delivery_time: 'delivery_time',
    #     customer_service: 'customer_service',
    #     review: 'review',
    #     anonymous: 'anonymous'
    #   )
    #   refute response['success'], response
    # end
    
    def test_update_settings
      stub_post_generic_success as: :settings
      response = @session.update_settings(
        refund_address: "mmqcyagCJgCKwSDZmRxLS8N9yUW4unM3Qs",
        refund_policy: "No refund policy",
        notifications: true,
        resolver: "https://resolver.onename.com/",
        terms_conditions: "No terms or conditions",
        language: "en-US",
        shipping_addresses: [""],
        country: "UNITED_STATES",
        time_zone: "-7",
        moderators: '',
        libbitcoin_server: nil,
        currency_code: "BTC"
      )
      assert response['success'], response
    end
    
    def test_update_settings_empty
      stub_post_generic_failure as: :settings
      response = @session.update_settings
      refute response['success'], response
    end
    
    def test_settings
      stub_get_settings
      response = @session.settings
      assert response['terms_conditions'], response
    end
    
    def test_connected_peers
      stub_get_connected_peers
      response = @session.connected_peers
      assert response['peers'], response
    end
    
    def test_routing_table
      stub_get_routing_table
      response = @session.routing_table
      assert response.first['nat_type'], response
    end
    
    def test_notifications
      stub_get_notifications
      response = @session.notifications
      assert response['notifications'], response
    end
    
    def test_mark_notification_as_read
      stub_post_generic_success as: :mark_notification_as_read
      response = @session.mark_notification_as_read id: 'c4c0bfd525a19e6a58686ff13b185ebc8b6a3e50'
      assert response['success'], response
    end
    
    def test_mark_notification_as_read_already_read
      stub_post_generic_failure as: :mark_notification_as_read
      response = @session.mark_notification_as_read id: 'c4c0bfd525a19e6a58686ff13b185ebc8b6a3e50'
      refute response['success'], response
    end
    
    def test_mark_notification_as_read_bogus
      stub_post_generic_failure as: :mark_notification_as_read
      response = @session.mark_notification_as_read id: '99'
      refute response['success'], response
    end
    
    def test_mark_notification_as_read_empty
      stub_post_generic_failure as: :mark_notification_as_read
      response = @session.mark_notification_as_read
      refute response['success'], response
    end
    
    def test_broadcast
      stub_post_broadcast
      response = @session.broadcast(message: 'hello world')
      # Is 'peers reached' valid json?
      assert_equal response['peers reached'], 1000, response 
      assert response['success'], response
    end
    
    def test_broadcast_empty
      stub_post_generic_failure as: :broadcast
      response = @session.broadcast
      refute response['success'], response
    end
    
    def test_btc_price
      stub_get_btc_price
      response = @session.btc_price
      assert response['currencyCodes'], response
    end
  end
end