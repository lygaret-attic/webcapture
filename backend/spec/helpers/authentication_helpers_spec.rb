require "rails_helper"

RSpec.describe API::AuthenticationHelpers do
  it "can generate self-consumable tokens" do
    input = { foo: :bar }
    token = AuthenticationHelpers.jwt_encode(input)
    expect(token).not_to eq(input)

    output = AuthenticationHelpers.jwt_decode(token)
    expect(output).to include("foo" => "bar")
  end

  it "generates unique tokens, even for same payload" do
    input = { foo: :bal }
    alpha = AuthenticationHelpers.jwt_encode(input)
    beta  = AuthenticationHelpers.jwt_encode(input)

    expect(alpha).not_to eq(beta)
  end

  it "doesn't choke on invalid tokens" do
    blah = AuthenticationHelpers.jwt_decode("blah")
    expect(blah).to be(false)

    # screw with the signature
    token     = AuthenticationHelpers.jwt_encode({})
    token[-1] = "t"
    blah      = AuthenticationHelpers.jwt_decode(token)
    expect(blah).to be(false)
  end
end
