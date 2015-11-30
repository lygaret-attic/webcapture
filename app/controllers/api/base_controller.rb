module API
  # Base controller for API functionality
  class BaseController < ActionController::Base
    include API::ErrorHandling
    include API::Authentication

    def require_json
      fail API::InvalidRequestError, "Accepts only JSON" unless request.format == 'json'
    end
  end
end
