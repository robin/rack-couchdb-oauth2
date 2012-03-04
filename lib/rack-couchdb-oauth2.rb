require 'rack/oauth2'
require 'couchrest'
require 'couchrest_model'
require 'active_support'

if defined? ActiveSupport::SecureRandom and not defined? SecureRandom
  # pre 3.2 activesupport version + ruby 1.8
  SecureRandom = ActiveSupport::SecureRandom
elsif not defined? SecureRandom
  if RUBY_VERSION > '1.9'
    # ruby 1.9 brings securerandom
    require 'securerandom'
  else
    begin
      require 'securerandom'
    rescue LoadError
      raise LoadError, "SecureRandom not found! Use ruby 1.9, downgrade activesupport below 3.2 or install webget-securerandom gem"
    end
  end
end

module Rack
  module CouchdbOAuth2
    autoload :Configuration, 'couchdb_oauth2/configuration'
    autoload :TokenEndpoint, 'couchdb_oauth2/token_endpoint'

    autoload :RequireBearerToken, 'couchdb_oauth2/resource/require_bearer_token'
    autoload :RequireClient, 'couchdb_oauth2/resource/require_client'
    
    module Model
      autoload :Base, 'couchdb_oauth2/model/base'
      autoload :Account, 'couchdb_oauth2/model/account'
    end
  end
end
autoload :Oauth2Token, 'couchdb_oauth2/model/oauth2_token'      
autoload :AccessToken, 'couchdb_oauth2/model/access_token'
autoload :Client, 'couchdb_oauth2/model/client'
autoload :RefreshToken, 'couchdb_oauth2/model/refresh_token'

