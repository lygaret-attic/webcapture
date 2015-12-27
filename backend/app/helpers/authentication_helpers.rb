module AuthenticationHelpers
  # Encode the payload with the realm key
  # Adds protocol specific keys to the payload, and overwrites
  # any conflicts: 'salt'...
  def self.jwt_encode(payload = {})
    payload[:salt] = saltgen
    key = keygen.generate_key(payload[:salt])
    JWT.encode(payload, key, "HS256")
  end

  # Decode the payload with the realm key
  # Uses the salt from the payload for key generation
  def self.jwt_decode(token)
    # nil pass, no verify to pull out the salt
    pre  = JWT.decode token, nil, false
    key  = keygen.generate_key(pre[0]["salt"])
    JWT.decode(token, key, true, algorithm: "HS256")[0]
  rescue
    false
  end

  private

  def self.saltgen
    SecureRandom.base64(12)
  end

  def self.keygen
    @keygen ||=
    begin
      base = Rails.application.secrets.secret_key_base
      ActiveSupport::KeyGenerator.new(base)
    end
  end
end
