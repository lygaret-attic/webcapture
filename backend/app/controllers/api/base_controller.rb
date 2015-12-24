module API
  # Base controller for API functionality
  class BaseController < ActionController::Base
    include API::ErrorHandling
    include API::Authentication
  end
end
