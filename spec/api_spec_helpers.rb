module APISpecHelpers
  module Controllers
    def authenticate(user, scopes = ["any"])
      session[:user_id] = user.is_a? User ? user.id : user_id
      session
    end
  end
end
