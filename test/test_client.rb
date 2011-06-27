require "helper"

class TestClient < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def setup
    create_client
  end
  
  def teardown
    destroy_client
  end
  
  def app
    Rack::Builder.new do
      run proc {|env| 
        client = Client.find_by_env(env)
        raise 'no client' if client.nil?
        [200, {}, 'OK']
      }
    end
  end
  
  def test_presents
    c = Client.new()
    assert(!c.save, "Failure message.")
    c.name = 'abc'
    assert(c.save, "Failure message.")
    
    c2 = Client.new :name => 'abc', :secret => 's'
    assert_nil(c2.secret)
    assert(!c2.save, "Failure message.")
    c.destroy
  end
  
  def test_find_by_env
    assert_raise(RuntimeError) { 
      get '/'
    }
    assert_raise(RuntimeError) { 
      get '/', :client_id => @client.identity, :client_secret =>'wrong secret'
    }
    assert_nothing_raised(RuntimeError) { 
      get '/', :client_id => @client.identity, :client_secret =>@client.secret
    }
    assert_raise(RuntimeError) { 
      get '/', :client_id => "wrong identity", :client_secret =>'wrong secret'
    }
  end
end