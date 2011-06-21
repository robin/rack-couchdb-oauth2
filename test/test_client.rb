require "helper"

class TestRequireClient < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def test_presents
    c = Client.new()
    assert(!c.save, "Failure message.")
    c.name = 'abc'
    assert(c.save, "Failure message.")
    
    c2 = Client.new :name => 'abc'
    assert(!c2.save, "Failure message.")
    c.destroy
  end
end