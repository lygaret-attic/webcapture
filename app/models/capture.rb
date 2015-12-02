class Capture < ActiveRecord::Base

  # foreign keys
  belongs_to :user

  # random unique key
  attr_readonly :key
  before_create -> { self[:key] = generate_key }

  # status is an enumerated value
  enum status: { pending: 0, merged: 1 }

  private

  def generate_key
    # 32 bytes of base64 =~ (4/3 * 32) chars
    SecureRandom.urlsafe_base64(32)[0, 32]
  end

end
