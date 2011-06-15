class AccessToken < CouchRest::Model::Base
  include CouchdbOAuth2::Model::Base
  include Oauth2Token
  self.default_lifetime = 15.minutes

  belongs_to :refresh_token
  property  :token, String
  property  :expires_at,  Time
  timestamps!
  
  def to_bearer_token(with_refresh_token = false)
    bearer_token = Rack::OAuth2::AccessToken::Bearer.new(
      :access_token => self.token,
      :expires_in => self.expires_in
    )
    if with_refresh_token
      bearer_token.refresh_token = self.refresh_token.token
    end
    bearer_token
  end
  
  private

  def setup
    super
    if self.refresh_token.nil? && self.account
      self.refresh_token = RefreshToken.create(:account => self.account, :client => self.client)
    end
  end
  
end