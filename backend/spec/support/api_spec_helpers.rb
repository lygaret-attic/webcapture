module APISpecHelpers
  module Controllers
    # Make the next request part of an authenticated session
    def session_auth(user, scopes = [:any])
      session[:user_id] = user.is_a?(User) ? user.id : user_id
      session[:scopes]  = scopes.clone
    end

    # The next request passes along the given basic auth creds.
    def basic_auth(email, password)
      creds = ActionController::HttpAuthentication::Basic.encode_credentials email, password
      request.headers["Authorization"] = creds
    end
  end
end

RSpec.configure do |c|
  c.include APISpecHelpers::Controllers, type: :controller
end
