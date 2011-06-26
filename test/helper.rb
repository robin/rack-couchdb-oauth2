require 'rubygems'
require 'bundler'
require 'rack/test'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack-couchdb-oauth2'

class User < CouchRest::Model::Base
  use_database 'users'
  include Rack::CouchdbOAuth2::Model::Account
  
  def self.pepper
    'pepper'
  end
  
  def self.find_account(identity)
    first_from_view(:by_email, identity)
  end
end

Rack::CouchdbOAuth2::Configuration.account_class = ::User

class Test::Unit::TestCase
  def assert_error_response(response)
    assert !response.ok?
    body = ActiveSupport::JSON.decode(response.body)
    assert_not_nil(body['error'])
    assert_nil(body['access_token'])
  end
  
  def create_client
    @client = Client.create(:name => 'test client')
  end
  
  def create_account
    @account = User.create(:email => 'test@example.com', :password => 'abc123', :password_confirmation => 'abc123' )
  end
  
  def destroy_client
    @client.destroy
  end
  
  def destroy_account
    @account.destroy
  end
end

class TestApp
  BODY = 'done'
  def call(env)
    [200, {"Content-Type" => "text/plain"}, BODY]
  end
end
