module Rack
  module CouchdbOAuth2
    class RequireClient
      CLIENT = "rack.oauth2.client"
      def initialize(app, &authenticator)
        @app = app
        @authenticator = authenticator
      end
      
      def call(env)
        authenticate!(env)
        @app.call(env)
      rescue Rack::OAuth2::Server::Abstract::Error => e
        e.realm = "Client Not Authorized"
        e.finish                
      end
      
      private

      def authenticate!(env)
        request = Request.new(env)
        client = request.client
        request.unauthorized!(:invalid_token) unless client
        if @authenticator
          request.unauthorized! unless @authenticator.call(request)          
        end
        env[CLIENT] = client
      end
      
      class Request < Rack::Request
        attr_reader :access_token
        attr_reader :client

        def initialize(env)
          super(env)
          @access_token = env[RequireBearerToken::ACCESS_TOKEN]
          @client = @access_token ? @access_token.client : nil
        end
      end

      class Unauthorized < Rack::OAuth2::Server::Resource::Unauthorized
        def scheme
          'client'
        end
      end

      module ErrorMethods
        include Rack::OAuth2::Server::Resource::ErrorMethods
        def unauthorized!(error = nil, description = nil, options = {})
          raise Unauthorized.new(error, description, options)
        end
      end

      Request.send :include, ErrorMethods
      
    end    
  end
end
