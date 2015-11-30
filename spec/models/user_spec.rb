require 'rails_helper'

RSpec.describe User, type: :model do

  context "authentication" do
    let(:user) {
      create(:user, password: "secret")
    }

    context("User.authenticate") do
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

    context("#authenticate!") do
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
end
