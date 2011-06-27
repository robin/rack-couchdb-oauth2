require 'helper'

class TestToken < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def setup
    create_client
    create_account
  end
  
  def teardown
    destroy_client
    destroy_account
  end
  
  def app
    Rack::Builder.new do
      map '/oauth2' do
        map '/token' do
          run Rack::CouchdbOAuth2::TokenEndpoint.new    
        end
      end
      
      map '/db' do
        use Rack::OAuth2::Server::Resource::Bearer, 'test' do |req|
          
        end
        run proc {|env| 
          token = AccessToken.find_by_env(env)
          raise 'no client' if token.nil?
          [200, {}, 'OK']
        }
      end
    end
  end
  
  def test_find_by_env
    post 'oauth2/token', :grant_type => 'password', :client_id => @client.identity, :client_secret => @client.secret, :username => @account.email, :password => 'abc123'
    assert last_response.ok?
    body = ActiveSupport::JSON.decode(last_response.body)
    access_token = body['access_token']
    refresh_token = body['refresh_token']
    assert_not_nil(access_token)
    assert_not_nil(refresh_token)
    assert_equal('bearer', body['token_type'])
    
    assert_raise(RuntimeError) { 
      header 'AUTHORIZATION', nil
      get 'db'
    }
    
    assert_nothing_raised(RuntimeError) { 
      header 'AUTHORIZATION', "Bearer #{access_token}"
      get 'db'
    }
    
    assert_raise(RuntimeError) { 
      header 'AUTHORIZATION', nil
      get 'db'
    }
  end
end