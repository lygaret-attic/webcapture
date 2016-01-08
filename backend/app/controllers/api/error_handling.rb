module API
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      # THIS MUST BE FIRST
      # According to docs: "[Error handlers] are searched from right to left, bottom to top, and up
      # the hierarchy." Hence, if this were at the end, it would be the first to invoke, and short-
      # circuit all other handlers.
      rescue_from Exception, with: :render_error

      rescue_from ActionController::RoutingError,          with: :render_not_found
      rescue_from ActionController::ParameterMissing,      with: :render_bad_request
      rescue_from ActionController::UnpermittedParameters, with: :render_bad_request
      rescue_from ActionController::UnknownFormat,         with: :render_unknown_format

      rescue_from ActiveRecord::RecordNotFound,            with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid,             with: :render_validation_error

      rescue_from API::InvalidRequestError,                with: :render_bad_request
      rescue_from API::AccessDeniedError,                  with: :render_access_denied
      rescue_from API::UnauthorizedError,                  with: :render_request_user
    end

    def render_response(status, data)
      fail ArgumentError "Must include a :message key!" unless data.key?(:message)

      data = data.merge(id: request.uuid)
      respond_to do |format|
        format.html { render "errors/response.html.erb", status: status, locals: { data: data } }
        format.org  { render "errors/response.org.erb", status: status, locals: { data: data } }
        format.json { render status: status, json: data }
        format.xml  { render status: status, xml: data }
      end
    end

    def render_error(e)
      trace = Rails.backtrace_cleaner.clean(e.backtrace).join("\n")
      Rails.logger.fatal("Exception: #{e}")
      Rails.logger.fatal(trace.indent(2))

      render_response(500, message: "Internal Server Error")
    end

    def render_not_found
      render_response(404, message: "Not Found")
    end

    def render_bad_request(e)
      render_response(400, message: "Invalid Request", detail: e.message)
    end

    def render_unknown_format(e)
      render_response(406, message: "Unknown Format")
    end

    def render_validation_error(e)
      render_response(400, message: "Invalid Resource", detail: e.record.errors)
    end

    def render_access_denied(ex)
      render_response(403, message: "Forbidden", detail: ex.message)
    end

    def render_request_user
      realm  = Rails.configuration.x.auth["realm"]
      method = request.xhr? ? %(Token realm="#{realm}") : %(Basic realm="#{realm}")
      headers["WWW-Authenticate"] = method

      render_response(401, message: "Unauthorized")
    end
  end
end
