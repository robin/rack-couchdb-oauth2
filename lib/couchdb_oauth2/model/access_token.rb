class AccessToken < CouchRest::Model::Base
  include Rack::CouchdbOAuth2::Model::Base
  include Oauth2Token
  self.default_lifetime = 15.minutes

  belongs_to :refresh_token
  timestamps!
  
  def self.find_by_env(env)
    token = find_bearer_token_in_env(env) || find_basic_token_in_env(env)
    (token.nil? || token.expired?) ? nil : token
  end
  
  def self.find_bearer_token_in_env(env)
      request = Rack::OAuth2::Server::Resource::Bearer::Request.new(env)
      return nil unless request && request.oauth2?
      request.setup!
      self.find_by_token request.access_token
    rescue
      nil    
  end
  
  def self.find_basic_token_in_env(env)
    auth = Rack::Auth::Basic::Request.new(env)
    
    return nil unless auth && auth.provided? && auth.username == 'bearer_access_token' && auth.credentials.last
    self.find_by_token auth.credentials.last
  end
  
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