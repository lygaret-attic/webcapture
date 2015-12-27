require "rails_helper"

RSpec.describe API::UsersController, type: :controller do
  let :user do
    create(:user, password: "secret")
  end

  describe "POST #token" do
    it "requires authentication" do
      post :token
      expect(response).to have_http_status(:unauthorized)
    end

    it "requires the :account scope" do
      session_auth(user, [:just_something])

      post :token
      expect(response).to have_http_status(:forbidden)
    end

    it "requires an explicit scopes parameter" do
      session_auth(user)

      post :token
      expect(response).to have_http_status(:bad_request)
    end

    it "requires an array for the scopes parameter" do
      session_auth(user)

      post :token, scopes: 4
      expect(response).to have_http_status(:bad_request)
    end

    it "generates a valid jwt token" do
      session_auth(user)

      post :token, scopes: [:special]
      expect(response).to have_http_status(:created)

      token = AuthenticationHelpers.jwt_decode(response.body)
      expect(token).to be_truthy
      expect(token["user_id"]).to eq(user.id)
      expect(token["scopes"]).to contain_exactly("special")
    end
  end

  describe "GET #show" do
    it "requires authentication" do
      get :show
      expect(response).to have_http_status(:unauthorized)
    end

    it "requires the :account scope" do
      session_auth(user, [:just_something])

      get :show
      expect(response).to have_http_status(:forbidden)
    end

    it "return success when authenticated" do
      session_auth(user)

      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    it "requires authentication" do
      put :update, email: "fake@fake.com", password: "secret"
      expect(response).to have_http_status(:unauthorized)
    end

    it "requires the account scope" do
      session_auth(user, [:different])

      put :update, email: "fake@fake.com", password: "secret"
      expect(response).to have_http_status(:forbidden)
    end

    context "parameters" do
      before { session_auth(user) }

      it "allows email" do
        expect { put :update, email: "new@email.com" }
          .to change { user.reload.email }
          .from(user.email)
          .to("new@email.com")

        expect(response).to have_http_status(204)
      end

      it "allows password" do
        expect { put :update, password: "changed" }
          .to change { user.reload.passhash }

        expect(response).to have_http_status(204)
      end

      it "disallows other fields" do
        expect { put :update, passhash: "pssh, what security?" }
          .not_to change { user.reload.passhash }

        expect(response).to have_http_status(204)
      end
    end
  end
end
