require "helper"

class TestRequireClient < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def test_presents
    a = User.new()
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
  
  def test_attr_protected
    a = User.new(:email => 'aaa@example.com', :encrypted_password => "pwd", :pepper => "pepper")
    assert_equal('aaa@example.com', a.email)
    assert_nil(a.encrypted_password)
    assert_nil(a.pepper)
  end
end