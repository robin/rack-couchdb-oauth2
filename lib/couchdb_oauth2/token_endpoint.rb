module Rack
  module CouchdbOAuth2
    class TokenEndpoint
      def call(env)
        authenticator.call(env)
      end

      private

      def authenticator
        Rack::OAuth2::Server::Token.new do |req, res|
          client = Client.find(req.client_id) || req.invalid_client!
          client.secret == req.client_secret || req.invalid_client!
          case req.grant_type
          when :authorization_code
            #not implemented
            req.unsupported_grant_type!
          when :password
            # NOTE: password is not hashed in this sample app. Don't do the same on your app.
            account_class = Rack::CouchdbOAuth2::Configuration.account_class
            account = req.username.nil? ? nil : account_class.find_account(req.username)
            req.invalid_grant! unless account && account.valid_password?(req.password)
            res.access_token = AccessToken.create(:client => client, :account => account).to_bearer_token(:with_refresh_token)
          when :client_credentials
            # NOTE: client is already authenticated here.
            res.access_token = AccessToken.create(:client => client).to_bearer_token
          when :refresh_token
            refresh_token = RefreshToken.find_by_token(req.refresh_token)
            req.invalid_grant! unless refresh_token && !refresh_token.expired? && refresh_token.client && refresh_token.client.id == client.id
            res.access_token = AccessToken.create(:client => client, :account => refresh_token.account, :refresh_token => refresh_token).to_bearer_token
          else
            # NOTE: extended assertion grant_types are not supported yet.
            req.unsupported_grant_type!
          end
        end
      end
    end
  end
end