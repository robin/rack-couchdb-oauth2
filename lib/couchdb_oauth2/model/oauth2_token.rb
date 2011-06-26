module Oauth2Token
  def self.included(klass)
    klass.class_eval do
      cattr_accessor :default_lifetime
      self.default_lifetime = 1.minute

      belongs_to :account, :class_name => Rack::CouchdbOAuth2::Configuration.account_class.to_s
      belongs_to :client
      
      property  :token, String
      property :expires_at, Time
      
      view_by :expires_at
      view_by :account_id
      view_by :client_id
      view_by :token
      
      before_validation :setup, :on => :create
      validates :client, :expires_at, :account, :presence => true
      validates :token, :presence => true, :uniqueness => true
    end
  end

  def expires_in
    (expires_at - Time.now.utc).to_i
  end

  def expired!
    self.expires_at = Time.now.utc
    self.save!
  end

  def expired?
    self.expires_at < Time.now.utc
  end
  
  def self.valid
    view(:by_expires_at, :startkey => Time.now.utc)
  end
  
  def self.find_by_token(token)
    return nil if token.nil? || token.empty?
    self.first_from_view(:by_token, token)
  end
  private

  def self.generate(bytes = 64)
    ActiveSupport::SecureRandom.base64(bytes)
  end
  
  def setup
    self.token = Oauth2Token.generate
    self.expires_at ||= self.default_lifetime.from_now
  end
end