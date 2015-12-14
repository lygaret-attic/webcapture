class Capture < ActiveRecord::Base
  include KeyManagement::Model

  # foreign keys
  belongs_to :user

  # status is an enumerated value
  enum status: { pending: 0, merged: 1 }

  # keep the org content useful
  before_save -> { self.content = process_org }

  # hide id from json
  def as_json(options = nil)
    super (options || {}).merge except: [:id, :user_id]
  end

  private

  def process_org
    # already have a webcapture property, set the value
    # need a webcapture property added, existing drawer
    # need a drawer added
    # - no headline
    # - bare headline
    # - headline with deadline
    capture_re = /^(\s*):webcapture: \w+.*$/
    if content.match capture_re
      content.sub capture_re, "\\1:webcapture: #{key}\2\n"
    else
      drawer_re = /^((\s*):PROPERTIES:.*$)$/
      if content.match drawer_re
        content.sub drawer_re, "\\1\n\\2:webcapture: #{key}"
      else
        deadline_re = /^(\s*)DEADLINE:[^\n]*$/m
        if content.match deadline_re
          content.sub deadline_re, "\\0\n\\1:PROPERTIES:\n\\1:webcapture: #{key}\n\\1:END:"
        else
          headline_re = /^(\s*)(\*+\s+)[^\n]*$/m
          headline_match = content.match headline_re
          if headline_match
            ident = ((headline_match[2].length) + (headline_match[1].length)).times.map{" "}.join("")
            content.sub headline_re, "\\0\n#{ident}:PROPERTIES:\n#{ident}:webcapture: #{key}\n#{ident}:END:"
          else
            ":PROPERTIES:\n:webcapture: #{key}\n:END:\n#{content}"
          end
        end
      end
    end
  end
end
