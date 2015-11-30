class User < ActiveRecord::Base
  include ::User::Authentication

  validates_presence_of :email, :passhash
end
