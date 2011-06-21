require "helper"

class TestRequireClient < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def test_presents
    a = Account.new()
    assert(!a.save, "Failure message.")
    a.email = 'abc@example.com'
    assert(!a.save, "Failure message.")
    a.password = 'abcdef'
    assert(!a.save, "Failure message.")
    a.password_confirmation = 'wrong'
    assert(!a.save, "Failure message.")
    a.password_confirmation = 'abcdef'
    assert(a.save, "Failure message.")
    a.destroy
  end
end