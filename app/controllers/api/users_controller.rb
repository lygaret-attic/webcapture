module API
  # API Controller for user and session management.
  class UsersController < BaseController

    # given an email and password, set up an authenticated session.
    def authenticate
      initiate_session User.authenticate!(cred_params[:email], cred_params[:password])
      head status: 204
    rescue ActiveRecord::RecordNotFound
      raise API::UnauthorizedError, "Invalid username or password"
    end

    # display the current user
    def show
      require_scope! :account

      render json: { email: current_user.email }
    end

    # update the current user
    def update
      require_scope! :account

      current_user.update!(update_params)
      head status: 204
    end

    private

    def cred_params
      params.permit(:email, :password)
    end

    def update_params
      params.permit(:email, :password)
    end

  end
end
