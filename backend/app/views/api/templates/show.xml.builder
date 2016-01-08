xml.instruct!
xml.template key: @template.key do
  @template.tokenized.each { |token|
    if token.is_a?(String)
      xml.cdata! token
    else
      attrs = { op: token[:op] }
      attrs[:mod]    = true if token[:mod]
      attrs[:prompt] = true if token[:mod]

      xml.escape attrs do
        xml.cdata! token[:content] if token.key? :content
      end
    end
  }
end
