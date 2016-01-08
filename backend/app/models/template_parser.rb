class TemplateParser < Parslet::Parser

  DELIMITERS = { "<" => ">", "[" => "]" }

  def self.parse(text)
    @ransform.apply(new.parse(text))
  end

  @ransform = Parslet::Transform.new do
    rule(text: simple(:x)) { String(x) }
    rule(code: simple(:x)) { String(x) }

    rule(op: { code: simple(:code), content: simple(:content) }) {
      { op: (code || "(").to_s, mod: false, content: String(content) }
    }

    rule(op: { code: simple(:code), modified: simple(:mod) }) {
      { op: code.to_s, mod: true }
    }

    rule(op: { code: "\\", reference: simple(:ref) }) {
      { op: "\\", reference: ref.to_s }
    }

    rule(op: { code: simple(:code), content: simple(:content), modified: simple(:mod) }) {
      { op: code.to_s, mod: true, content: String(content) }
    }

    rule(op: { code: simple(:code), content: simple(:content), prompt: simple(:prompt) }) {
      { op: (code || "{").to_s, prompt: true, content: String(content) }
    }

    rule(op: { code: simple(:code), content: simple(:content), modified: simple(:mod), prompt: simple(:prompt) }) {
      { op: (code || "{").to_s, mod: true, prompt: true, content: String(content) }
    }
  end

  rule(:simple_op)     { match("[?tTuUiaAlcxkKnfF%]").as(:code) }
  rule(:keyword_op)    { str(":").as(:code) >> match('\S').repeat(1).as(:content) }

  rule(:modifiable_op) { str("^").as(:modified) >> (match("[gGtTuUCL]").as(:code) | prompt_op) }
  rule(:prompt_sel_op) { str("\\").as(:code) >> match["0-9"].repeat(1).as(:reference) }
  rule(:prompt_op)     {
    str("{").as(:prompt) >> match["^}"].repeat.as(:content) >> str("}") >>
      match("[ptTuU]").maybe.as(:code)
  }

  rule(:delimited_op)  {
    match("[#{Regexp.escape(DELIMITERS.keys.join)}]").capture(:delim).as(:code) >>
      (dynamic { |_, context|
         delim = DELIMITERS[context.captures[:delim].to_s]
         match("[^#{Regexp.escape(delim)}]").repeat(0).as(:content) >> str(delim)
       })
  }

  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:sexp)      { str("(") >> sexp_body >> str(")") }
  rule(:sexp_body) { (sexp | match["^()"]).repeat }
  rule(:sexp_op)   { str("(").present?.as(:code) >> sexp.as(:content) }

  rule(:operator) { simple_op | modifiable_op | keyword_op | prompt_op | prompt_sel_op | delimited_op | sexp_op }

  rule(:escape)   { str("%") >> operator.as(:op) }
  rule(:text)     { match["^%"].repeat(1).as(:text) }
  rule(:template) { (escape | text).repeat }
  root(:template)

end
