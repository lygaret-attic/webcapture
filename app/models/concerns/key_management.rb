module KeyManagement
  module Model
    extend ActiveSupport::Concern

    included do
      # random unique key
      attr_readonly :key
      before_save -> { self.key = KeyManagement.generate_key }, if: :new_record?
    end
  end

  def self.generate_key
    # 32 bytes of base64 =~ (4/3 * 32) chars
    SecureRandom.urlsafe_base64(32)[0, 32]
  end
end
