class Client < CouchRest::Model::Base
  include CouchdbOAuth2::Model::Base
  
  property :name,      String
  property :redirect_url,   String
  property :website,        String
  property :secret,         String
  timestamps!
  
  before_validation :setup, :on => :create
  
  def setup
    if self.secret.nil?
      self.secret = ActiveSupport::SecureRandom.base64(64)
    end
  end
  
  def identity
    self['_id']
  end
end