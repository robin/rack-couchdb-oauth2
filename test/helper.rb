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

class Test::Unit::TestCase
  def assert_error_response(response)
    assert !response.ok?
    body = ActiveSupport::JSON.decode(response.body)
    assert_not_nil(body['error'])
    assert_nil(body['access_token'])
  end
end

class TestApp
  BODY = 'done'
  def call(env)
    [200, {"Content-Type" => "text/plain"}, BODY]
  end
end
