require 'helper'

class TestRackCouchdbOauth2 < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def setup
    Rack::CouchdbOAuth2::Configuration.pepper = 'pepper'
    create_client
    create_account
  end
  
  def teardown
    destroy_client
    destroy_account
  end
  
  def app
    Rack::Builder.new do
      map '/db' do
        use Rack::CouchdbOAuth2::RequireBearerToken
        run TestApp.new
      end
    
      map '/oauth2' do
        map '/token' do
          run Rack::CouchdbOAuth2::TokenEndpoint.new    
        end
      end
    end
  end
  
  def test_oauth2_token_by_password_error
    
    post 'oauth2/token', :grant_type => 'password', :client_id => @client.identity, :client_secret =>'wrong secret', :username => @account.email, :password => 'abc123'
    assert_error_response last_response
    assert_equal(401, last_response.status)
    
    post 'oauth2/token', :grant_type => 'password', :client_id => 'wrong identity', :client_secret => @client.secret, :username => @account.email, :password => 'abc123'
    assert_error_response last_response
    assert_equal(401, last_response.status)

    post 'oauth2/token', :grant_type => 'password', :client_id => @client.identity, :client_secret => @client.secret, :username => 'bademail', :password => 'abc123'
    assert_error_response last_response
    assert_equal(400, last_response.status)
    
    post 'oauth2/token', :grant_type => 'password', :client_id => @client.identity, :client_secret => @client.secret, :username => @account.email, :password => 'badpassword'
    assert_error_response last_response
    assert_equal(400, last_response.status)
  end
  
  def test_oauth2_token_by_password
    header 'AUTHORIZATION', nil
    get 'db'
    assert_error_response last_response
    
    post 'oauth2/token', :grant_type => 'password', :client_id => @client.identity, :client_secret => @client.secret, :username => @account.email, :password => 'abc123'
    assert last_response.ok?
    body = ActiveSupport::JSON.decode(last_response.body)
    access_token = body['access_token']
    refresh_token = body['refresh_token']
    assert_not_nil(access_token)
    assert_not_nil(refresh_token)
    assert_equal('bearer', body['token_type'])

    header 'AUTHORIZATION', nil
    get 'db'
    assert_error_response last_response
    assert_not_equal(TestApp::BODY, last_response.body)

    header 'AUTHORIZATION', "Bearer badtoken"
    get 'db'
    assert_error_response last_response
    assert_not_equal(TestApp::BODY, last_response.body)
    
    header 'AUTHORIZATION', "Bearer #{access_token}"
    get 'db'
    assert last_response.ok?
    assert_equal(TestApp::BODY, last_response.body)
    
    AccessToken.find_by_token(access_token).expired!

    header 'AUTHORIZATION', "Bearer #{access_token}"
    get 'db'
    assert_error_response last_response
    assert_not_equal(TestApp::BODY, last_response.body)
    
    header 'AUTHORIZATION', nil
    get 'db'
    assert_error_response last_response
    assert_not_equal(TestApp::BODY, last_response.body)
  end
  
  def test_oauth2_token_by_refresh_token
    header 'AUTHORIZATION', nil
    get 'db'
    assert_error_response last_response
    
    post 'oauth2/token', :grant_type => 'password', :client_id => @client.identity, :client_secret => @client.secret, :username => @account.email, :password => 'abc123'
    assert last_response.ok?
    body = ActiveSupport::JSON.decode(last_response.body)
    access_token = body['access_token']
    refresh_token = body['refresh_token']
    assert_not_nil(access_token)
    assert_not_nil(refresh_token)
    assert_equal('bearer', body['token_type'])

    post 'oauth2/token', :grant_type => 'refresh_token', :client_id => @client.identity, :client_secret => @client.secret, :refresh_token => 'badtoken'
    assert_error_response last_response

    post 'oauth2/token', :grant_type => 'refresh_token', :client_id => 'bad identity', :client_secret => @client.secret, :refresh_token => refresh_token
    assert_error_response last_response

    post 'oauth2/token', :grant_type => 'refresh_token', :client_id => @client.identity, :client_secret => 'badsecret', :refresh_token => refresh_token
    assert_error_response last_response
    
    post 'oauth2/token', :grant_type => 'refresh_token', :client_id => @client.identity, :client_secret => @client.secret, :refresh_token => refresh_token
    assert last_response.ok?
    assert last_response.ok?
    body = ActiveSupport::JSON.decode(last_response.body)
    new_access_token = body['access_token']
    assert_not_nil(new_access_token)
    assert_not_equal(access_token, new_access_token)
    
  end
end
