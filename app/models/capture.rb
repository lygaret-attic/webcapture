class Capture < ActiveRecord::Base

  # foreign keys
  belongs_to :user

  # random unique key
  attr_readonly :key
  before_create -> { self[:key] = generate_key }

  # status is an enumerated value
  enum status: { pending: 0, merged: 1 }

  # display as an org-mode entry
  # with custom properties added
  def to_org
    @org ||= generate_org
  end

  private

  def generate_key
    # 32 bytes of base64 =~ (4/3 * 32) chars
    SecureRandom.urlsafe_base64(32)[0, 32]
  end

  def generate_org
    # replace a special template var with the webcapture key
    content.gsub(/\$\{:webcapture\}$/, key)
  end

end
