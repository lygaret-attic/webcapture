require "rails_helper"

RSpec.describe Capture, type: :model do
  context "key management" do
    it "should generate a random key on create" do
      c = create(:capture)
      expect(c.reload.key).to be_present
      expect(c.key.length).to eq(32)
    end

    it "should not be settable on create" do
      c = create(:capture, key: "heh")
      expect(c.reload.key).to be_present
      expect(c.key).not_to eq("heh")
    end

    it "should not be settable after create" do
      c   = create(:capture)
      key = c.key

      # change it
      c.update!(key: "heh")
      expect(c.reload.key).to eq(key)
    end
  end

  context "statuses" do
    it "should be able to update the status" do
      c = create(:capture)

      expect(c.pending?).to be true
      expect(c.merged?).to be false

      c.merged!

      expect(c.reload.pending?).to be false
      expect(c.merged?).to be true
    end
  end

  context "user stuff" do
    it "should belong to a user" do
      c = create(:capture)
      expect(c.user).to be_present
      expect(c.user.captures.include? c).to be true
    end
  end

  context "as_json output" do
    it "should not include id" do
      c = create(:capture)
      json = c.as_json
      expect(json.keys).not_to include(:id)
    end

    it "should not include user_id" do
      c = create(:capture)
      json = c.as_json
      expect(json.keys).not_to include(:user_id)
    end
  end

  context "org parsing" do
    it "should add a properties drawer if one wasn't included" do
      input  = "* Some Headline"
      c      = create(:capture, content: input)

      output = ["* Some Headline",
                "  :PROPERTIES:",
                "  :webcapture: #{c.key}",
                "  :END:"].join("\n")
      expect(c.content).to eq(output)
    end

    it "should only add the webcapture key if there was a drawer already" do
      input = ["* Some Headline",
               "  :PROPERTIES:",
               "  :key: value",
               "  :END:"].join("\n")
      c = create(:capture, content: input)

      output = ["* Some Headline",
                "  :PROPERTIES:",
                "  :webcapture: #{c.key}",
                "  :key: value",
                "  :END:"].join("\n")
      expect(c.content).to eq(output)
    end

    it "should place the drawer in the correct location with respect to DEADLINE" do
      input = ["* Some Headline",
               "  DEADLINE: <2015-12-12>",
               "  Some context about the headline above"].join("\n")
      c = create(:capture, content: input)

      output = ["* Some Headline",
                "  DEADLINE: <2015-12-12>",
                "  :PROPERTIES:",
                "  :webcapture: #{c.key}",
                "  :END:",
                "  Some context about the headline above"].join("\n")
      expect(c.content).to eq(output)
    end

    it "bug #1" do
      input = ["* <2015-12-10> [[google.com/blah]]",
               "  Balh blah blah"].join("\n")
      c = create(:capture, content: input)

      output = ["* <2015-12-10> [[google.com/blah]]",
                "  :PROPERTIES:",
                "  :webcapture: #{c.key}",
                "  :END:",
                "  Balh blah blah"].join("\n")
      expect(c.content).to eq(output)
    end
  end
end
