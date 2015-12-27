module API
  # API Controller for user and session management.
  class UsersController < BaseController

    # given basic auth, return a valid authentication token and the user
    def token
      require_scope! :account, basic: true
      scopes  = parse_scopes! params.require(:scopes)

      payload = { user_id: current_user.id, scopes: scopes }
      token   = AuthenticationHelpers.jwt_encode(payload)
      render status: 201, text: token
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

    def parse_scopes!(incoming)
      unless incoming.present? && incoming.is_a?(Array)
        fail API::InvalidRequestError, "scopes is not present or not array"
      end

      incoming.flatten.map(&:to_s).map(&:to_sym)
    end

    def update_params
      params.permit(:email, :password)
    end

  end
end
