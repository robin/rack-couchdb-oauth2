require 'bcrypt'

module Rack
  module CouchdbOAuth2
    module Model
      module Account
        def self.included(klass)
          klass.class_eval do
            property  :email,   String
            property  :encrypted_password,  String
            timestamps!

            view_by   :email

            validates_uniqueness_of :email
            validates_presence_of :encrypted_password, :on => :create, :message => "can't be blank"

            attr_reader :password

            def self.stretches
              5
            end

            def self.pepper
              raise('you need to set your own Rack::CouchdbOAuth2::Configuration.pepper')
            end

            def self.secure_compare(a, b)
              return false if a.blank? || b.blank? || a.bytesize != b.bytesize
              l = a.unpack "C#{a.bytesize}"

              res = 0
              b.each_byte { |byte| res |= byte ^ l.shift }
              res == 0
            end

            def self.find_account(identity)
              raise 'implement me'
            end
          end
        end

        def password=(new_password)
          @password = new_password
          self.encrypted_password = password_digest(@password) if @password.present?
        end

        def valid_password?(password)
          return false if encrypted_password.blank?
          bcrypt   = ::BCrypt::Password.new(self.encrypted_password)
          password = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt.salt)
          Account.secure_compare(password, self.encrypted_password)
        end

        def clean_up_passwords
          self.password = self.password_confirmation = ""
        end

        # A reliable way to expose the salt regardless of the implementation.
        def authenticatable_salt
          self.encrypted_password[0,29] if self.encrypted_password
        end

        def access_tokens
          AccessToken.view(:by_account_id, :key => self['_id'])
        end

        def refresh_tokens
          RefreshToken.view(:by_account_id, :key => self['_id'])
        end

        def self.find_user(identity)

        end
        protected

        # Downcase case-insensitive keys
        def downcase_keys
          (self.class.case_insensitive_keys || []).each { |k| self[k].try(:downcase!) }
        end

        # Digests the password using bcrypt.
        def password_digest(password)
          ::BCrypt::Password.create("#{password}#{self.class.pepper}", :cost => self.class.stretches).to_s
        end

      end      
    end
  end
end