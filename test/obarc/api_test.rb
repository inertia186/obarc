require 'test_helper'

module OBarc
  class ApiTest < OBarc::Test
    def setup
      stub_post_login
      # This is how you do an ad-hoc session with full overrides:
      options = {
        protocol: 'http',
        server_host: 'localhost',
        server_port: '18469',
        api_version: 'v1',
        verify_ssl: true,
        username: 'username',
        password: 'password'
      }
      @session = OBarc.login!(options)
      
      # The above is for deep testing or for a VPS that wants full control over
      # multiple instances.  If you just run one instance, usually you'll want
      # to do simply:
      #
      # session = OBarc::Session.new(username: 'username', password: 'password')
      # ... or ...
      # session = OBarc::Session.new(server_host: 'foo', username: 'username', password: 'password')
    end

    def test_method_missing
      begin
        OBarc::Api.bogus
        fail 'did not expect missing method not to be missing'
      rescue NoMethodError => _
        # success
      end
    end

    def test_login
      response = OBarc::Api.post_login(@session)
      assert response.body['success'], response.body
    end
    
    def test_btc_price
      stub_get_btc_price
      response = OBarc::Api.get_btc_price(@session)
      assert response.body['currencyCodes'], response.body
    end
    
    def test_connected_peers
      stub_get_connected_peers
      response = OBarc::Api.get_connected_peers(@session)
      assert response.body['peers'], response.body
    end
    
    def test_routing_table
      stub_get_routing_table
      response = OBarc::Api.get_routing_table(@session)
      assert response.body['nat_type'], response.body
    end
    
    def test_settings
      stub_get_settings
      response = OBarc::Api.get_settings(@session)
      assert response.body['terms_conditions'], response.body
    end
  end
end