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

    def current_user
      parse_request_auth unless @current_user.present?
      @current_user
    end

    def current_scopes
      parse_request_auth unless @current_scopes.present?
      @current_scopes
    end

    def initiate_session(u)
      session[:user_id] = u.is_a?(User) ? u.id : u
      parse_from_session
    end

    def require_user!
      fail API::UnauthorizedError, "Unauthorized" unless current_user
    end

    def require_scope!(scope)
      require_user!
      fail API::AccessDeniedError, scope unless
        current_scopes && (current_scopes.include?(scope) || current_scopes.include?(:any))
    end

    private

    def parse_request_auth
      parse_from_session || parse_from_basicauth || parse_from_token
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

    # TODO: implement JWT authentication
    def parse_from_token
      false
    end
  end
end
