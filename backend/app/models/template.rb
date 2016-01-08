class Template < ActiveRecord::Base

  include KeyManagement::Model

  # foreign keys
  belongs_to :user

  # client specific properties
  serialize :properties, JSON

  # validate that the template can be parsed
  validates_presence_of :template
  validate :valid_parse?, if: :template_changed?

  # hide id and user-id from json
  def as_json(options = nil)
    super (options || {}).merge except: [:id, :user_id]
  end

  def tokenized
    TemplateParser.parse(template)
  end

  private

  def valid_parse?
    TemplateParser.parse(template) && true
  rescue => ex
    errors.add(:template, "Template parse failed: #{ex}")
  end

end
