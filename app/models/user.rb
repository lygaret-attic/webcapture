class User < ActiveRecord::Base

  include ::User::Authentication

  validates :email, presence: true
  validates :passhash, presence: true

end
