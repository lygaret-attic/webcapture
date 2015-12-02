require "rails_helper"

RSpec.describe User, type: :model do
  context "referential integrity" do
    it "can't have duplicate email addresses" do
      expect {
        u = create(:user)
        create(:user, email: u.email)
      }.to raise_error ActiveRecord::RecordNotUnique
    end

    it "must have a password" do
      expect {
        create(:user, password: nil)
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "must have an email" do
      expect {
        create(:user, email: nil)
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  context "authentication" do
    let(:user) { create(:user, password: "secret") }

    context "User.authenticate" do
      it "can fail authentication for bad passwords" do
        result = User.authenticate(user.email, "badpass")
        expect(result).not_to eq(user)
      end

      it "can authenticate a user" do
        result = User.authenticate(user.email, "secret")
        expect(result).to eq(user)
      end

      it "doesn't store the password" do
        result = User.authenticate(user.email, "secret")
        expect(result.attributes.value?("secret")).to be_falsey
      end
    end

    context "#authenticate!" do
      it "passes along the user on success" do
        result = User.authenticate!(user.email, "secret")
        expect(result).to eq(user)
      end

      it "raises a not found error if the user can't be authenticated" do
        expect {
          User.authenticate!(user.email, "incorrect")
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context "capture relationships" do
    let(:user) { create(:user) }

    it "should own a collection of captures" do
      create_list(:capture, 3, user: user)
      expect(user.captures.count).to eq(3)
    end

    it "should have a status scopes" do
      create_list(:capture, 2, user: user)
      create(:capture, user: user, status: :merged)

      expect(user.captures.count).to eq(3)
      expect(user.captures.pending.count).to eq(2)
      expect(user.captures.merged.count).to eq(1)
    end
  end
end
