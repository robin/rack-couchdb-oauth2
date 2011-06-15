module Rack
  module CouchdbOAuth2
    class RequireBearerToken < Rack::OAuth2::Server::Resource
      ACCESS_TOKEN = "rack.oauth2.couchdb.access_token"
      def initialize(app)
        super(app, "Rack CouchdbOAuth2 RequireBearerToken") do |req|
          token = req.couchdb_access_token
          if token.nil? || token.expired?
            req.invalid_token!
          else
            token
          end
        end
      end
      
      def call(env)
        self.request = Request.new(env).setup!
        self.request.invalid_token! unless self.request.oauth2?
        env[ACCESS_TOKEN] = self.request.couchdb_access_token if self.request.couchdb_access_token
        super(env)
      rescue Rack::OAuth2::Server::Abstract::Error => e
        e.realm ||= realm
        e.finish
      end
      
      class Request < Rack::OAuth2::Server::Resource::Bearer::Request
        attr_reader :couchdb_access_token
        def initialize(env)
          super(env)
        end
        
        def setup!
          super
          @couchdb_access_token =  AccessToken.find_by_token(self.access_token) if self.access_token          
          self
        end
      end
      
    end
    
  end  
end
