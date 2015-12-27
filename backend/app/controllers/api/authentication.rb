module API
  # Authentication support for controllers
  #
  # Looks for a current user in the session, basic auth, or JWT token (in headers)
  # in that order, and sets the user and current scope. Scope is [:any] for session
  # and basic auth, and defined by the token in JWT. :any scope will allow any
  # required scope.
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :current_user
    end

    def current_user(options = nil)
      parse_request_auth(options) unless @current_user.present?
      @current_user
    end

    def current_scopes(options = nil)
      parse_request_auth(options) unless @current_scopes.present?
      @current_scopes
    end

    def initiate_session(u)
      session[:user_id] = u.is_a?(User) ? u.id : u
      parse_from_session
    end

    def require_user!(options = nil)
      fail API::UnauthorizedError, "Unauthorized" unless current_user(options)
    end

    def require_scope!(scope, options = nil)
      require_user!(options)
      fail API::AccessDeniedError, scope unless
        current_scopes && (current_scopes.include?(scope) || current_scopes.include?(:any))
    end

    private

    def parse_request_auth(options)
      options ||= {}
      auth      = parse_from_session || parse_from_basicauth
      auth    ||= parse_from_token unless options[:basic]
    end

    def parse_from_session
      u = User.find_by_id(session[:user_id])
      return false unless u.present?

      @current_user   = u
      @current_scopes = session[:scopes] || [:any]
    end

    def parse_from_basicauth
      authenticate_with_http_basic do |email, password|
        u = User.authenticate(email, password)
        return false unless u.present?

        @current_user   = u
        @current_scopes = [:any]
      end
    end

    def parse_from_token
      authenticate_with_http_token do |token, _|
        token = AuthenticationHelpers.jwt_decode(token)
        return false unless token

        @current_user   = User.find_by_id(token["user_id"])
        @current_scopes = token["scopes"].map(&:to_sym)
      end
    end
  end
end
