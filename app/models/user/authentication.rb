class User
  # Authentication related code for User
  module Authentication
    extend ActiveSupport::Concern

    included do
      has_secure_password
      alias_attribute :password_digest, :passhash
    end

    class_methods do
      # Find a user by email and password.
      # Returns `user` or `false
      def authenticate(email, password)
        User.find_by(email: email).try(:authenticate, password)
      end

      # Find a user by email and password.
      # Returns `user` if an authenticated user exists, or raises
      #   `ActiveRecord::RecordNotFound`
      def authenticate!(email, password)
        user = authenticate(email, password)
        user || fail(ActiveRecord::RecordNotFound, "couldn't authenticate user")
      end
    end
  end
end
