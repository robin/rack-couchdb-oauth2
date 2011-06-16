require "helper"

class TestRequireClient < Test::Unit::TestCase
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
    @app ||= Rack::Builder.new do
      map '/db' do
        use Rack::CouchdbOAuth2::RequireBearerToken
        use Rack::CouchdbOAuth2::RequireClient
        run TestApp.new
      end
    
      map '/oauth2' do
        map '/token' do
          run Rack::CouchdbOAuth2::TokenEndpoint.new    
        end
      end
    end
  end
  
  def change_to_false_client_id
    @app ||= Rack::Builder.new do
      map '/db' do
        use Rack::CouchdbOAuth2::RequireBearerToken
        use Rack::CouchdbOAuth2::RequireClient do |req|
          req.client.identity == 'false id'
        end
        run TestApp.new
      end
    
      map '/oauth2' do
        map '/token' do
          run Rack::CouchdbOAuth2::TokenEndpoint.new    
        end
      end
    end    
  end

  def change_to_use_client_id
    identity = @client.identity
    @app ||= Rack::Builder.new do
      map '/db' do
        use Rack::CouchdbOAuth2::RequireBearerToken
        use Rack::CouchdbOAuth2::RequireClient do |req|
          req.client.identity == identity
        end
        run TestApp.new
      end
    
      map '/oauth2' do
        map '/token' do
          run Rack::CouchdbOAuth2::TokenEndpoint.new    
        end
      end
    end    
  end

  def test_require_client
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
    
    header 'AUTHORIZATION', "Bearer #{access_token}"
    get 'db'
    assert last_response.ok?
    assert_equal(TestApp::BODY, last_response.body)    
  end
  
  def test_require_client_with_wrong_id
    change_to_false_client_id
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
    
    header 'AUTHORIZATION', "Bearer #{access_token}"
    get 'db'
    assert_error_response last_response
  end
  
  def test_require_client_with_correct_id
    change_to_use_client_id
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
    
    header 'AUTHORIZATION', "Bearer #{access_token}"
    get 'db'
    assert last_response.ok?
    assert_equal(TestApp::BODY, last_response.body)    
    
  end
end