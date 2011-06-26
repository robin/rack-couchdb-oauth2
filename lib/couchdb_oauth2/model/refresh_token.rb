class RefreshToken < CouchRest::Model::Base
  include Rack::CouchdbOAuth2::Model::Base
  include Oauth2Token
  timestamps!
  
  self.default_lifetime = 1.month
  
end