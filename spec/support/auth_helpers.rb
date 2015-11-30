module SpecAuthHelpers
  def basic_auth(user, password)
    ActionController::HttpAuthentication::Basic.encode_credentials user, password
  end
end

RSpec.configure do |c|
  c.include SpecAuthHelpers
end
