class User < ActiveRecord::Base

  has_many :captures
  validates :email, presence: true
  validates :passhash, presence: true

  # features
  include ::User::Authentication

end
