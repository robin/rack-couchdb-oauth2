module CouchdbOAuth2
  module Model
    module Base
      def self.included(klass)
        klass.class_eval do
          use_database klass.name.tableize
        end
      end      
    end
  end
  
end