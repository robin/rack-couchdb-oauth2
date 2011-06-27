class Client < CouchRest::Model::Base
  include Rack::CouchdbOAuth2::Model::Base
  
  property :name,      String
  property :redirect_url,   String
  property :website,        String
  property :secret,         String, :protected => true
  timestamps!
  
  before_validation :setup, :on => :create
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :secret
  
  def setup
    if self.secret.nil?
      self.secret = ActiveSupport::SecureRandom.base64(64)
    end
  end
  
  def identity
    self['_id']
  end
  
  def self.find_by_env(env)
    request = Rack::OAuth2::Server::Token::Request.new(env)
    client = Client.find(request.client_id)
    client if client && client.secret == request.client_secret
  end
end