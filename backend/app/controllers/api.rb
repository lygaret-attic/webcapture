module API
  class InvalidRequestError < StandardError; end
  class AccessDeniedError < StandardError; end
  class UnauthorizedError < StandardError; end

  Mime::Type.register "text/frag", :frag, %w( text/json text/x-json application/json )
end
