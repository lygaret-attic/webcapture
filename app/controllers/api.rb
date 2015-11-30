module API
  class InvalidRequestError < StandardError; end
  class AccessDeniedError < StandardError; end
  class UnauthorizedError < StandardError; end
end
