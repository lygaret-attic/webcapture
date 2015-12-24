class Template < ActiveRecord::Base
  include KeyManagement::Model

  # foreign keys
  belongs_to :user

  # client specific properties
  serialize :properties, JSON

  # hide id and user-id from json
  def as_json(options = nil)
    super (options || {}).merge except: [:id, :user_id]
  end
end
