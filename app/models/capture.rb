class Capture < ActiveRecord::Base

  # foreign keys
  belongs_to :user

  # random unique key
  attr_readonly :key
  before_save -> { self.key = generate_key }, if: :new_record?

  # keep the org content useful
  before_save -> { self.content = process_org }

  # status is an enumerated value
  enum status: { pending: 0, merged: 1 }

  private

  def generate_key
    # 32 bytes of base64 =~ (4/3 * 32) chars
    SecureRandom.urlsafe_base64(32)[0, 32]
  end

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
