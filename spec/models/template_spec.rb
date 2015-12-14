require "rails_helper"

RSpec.describe Template, type: :model do
  context "key management" do
    it "should generate a random key on create" do
      c = create(:template)
      expect(c.reload.key).to be_present
      expect(c.key.length).to eq(32)
    end

    it "should not be settable on create" do
      c = create(:template, key: "heh")
      expect(c.reload.key).to be_present
      expect(c.key).not_to eq("heh")
    end

    it "should not be settable after create" do
      c   = create(:template)
      key = c.key

      # change it
      c.update!(key: "heh")
      expect(c.reload.key).to eq(key)
    end
  end

  context "user stuff" do
    it "should belong to a user" do
      c = create(:capture)
      expect(c.user).to be_present
      expect(c.user.captures.include? c).to be true
    end
  end
end
