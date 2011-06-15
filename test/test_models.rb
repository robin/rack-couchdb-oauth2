require "helper"

class TestModels < Test::Unit::TestCase
  def test_pepper_setting
    assert_raise(RuntimeError) { Account.create(:email => 'abc@example.com', :password => 'abc123') }
    assert_nothing_raised(RuntimeError) { 
      Rack::CouchdbOAuth2::Configuration.pepper = 'pepper'
      a = Account.create(:email => 'abc@example.com', :password => 'abc123')
      a.destroy
    }
  end
end