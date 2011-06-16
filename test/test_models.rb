require "helper"

class TestModels < Test::Unit::TestCase
  class AccountWithoutPepper < CouchRest::Model::Base
    use_database 'accounts'
    include Rack::CouchdbOAuth2::Model::Account
    
  end
  
  def test_pepper_setting
    assert_raise(RuntimeError) { AccountWithoutPepper.create(:email => 'abc@example.com', :password => 'abc123') }
    assert_nothing_raised(RuntimeError) { 
      a = Account.create(:email => 'abc@example.com', :password => 'abc123')
      a.destroy
    }
  end
end