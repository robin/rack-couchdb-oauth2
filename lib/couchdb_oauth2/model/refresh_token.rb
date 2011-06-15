class RefreshToken < CouchRest::Model::Base
  include CouchdbOAuth2::Model::Base
  include Oauth2Token
  belongs_to :account
  belongs_to :client
  property  :token,   String
  property :expires_at, Time
  timestamps!
  
  self.default_lifetime = 1.month
  
end