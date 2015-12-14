class User < ActiveRecord::Base

  has_many :captures # db cascade delete
  has_many :templates # db cascade delete

  validates :email, presence: true
  validates :passhash, presence: true

  # features
  include ::User::Authentication

end
