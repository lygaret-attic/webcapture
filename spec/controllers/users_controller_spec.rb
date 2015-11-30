require 'rails_helper'

RSpec.describe API::UsersController, type: :controller do

  let :user do
    create(:user, password: 'secret')
  end

  describe "POST #authenticate" do
    it "can authenticate a session" do
      post :authenticate, email: user.email, password: 'secret'
      expect(response).to have_http_status(204)
      expect(session[:user_id]).to eq(user.id)
    end

    it "fails with :unauthenticated" do
      post :authenticate, email: 'fake@fake.com', password: 'secret'
      expect(response).to have_http_status(:unauthorized)
    end

    it "requires password" do
      post :authenticate, email: 'fake@fake.com'
      expect(response).to have_http_status(401)
    end

    it "requires email" do
      post :authenticate, password: 'secret'
      expect(response).to have_http_status(401)
    end
  end

  describe "GET #show" do
    it "requires authentication" do
      get :show
      expect(response).to have_http_status(:unauthorized)
    end

    it "requires the :account scope" do
      session[:user_id] = user.id
      session[:scopes]  = [:just_something]

      get :show
      expect(response).to have_http_status(:forbidden)
    end

    it "return success when authenticated" do
      session[:user_id] = user.id
      session[:scopes]  = [:any]

      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    it "requires authentication" do
      put :update, email: 'fake@fake.com', password: 'secret'
      expect(response).to have_http_status(:unauthorized)
    end

    it "requires the account scope" do
      session[:user_id] = user.id
      session[:scopes]  = [:different]

      put :update, email: 'fake@fake.com', password: 'secret'
      expect(response).to have_http_status(:forbidden)
    end

    context "parameters" do
      # login
      before {
        session[:user_id] = user.id
        session[:scopes]  = [:any]
      }

      it "allows email" do
        expect { put :update, email: 'new@email.com' }
          .to change { user.reload.email }
          .from(user.email)
          .to('new@email.com')

        expect(response).to have_http_status(204)
      end

      it "allows password" do
        expect { put :update, password: 'changed' }
          .to change { user.reload.passhash }

        expect(response).to have_http_status(204)
      end

      it "disallows other fields" do
        expect { put :update, passhash: 'pssh, what security?' }
          .not_to change { user.reload.passhash }

        expect(response).to have_http_status(204)
      end
    end
  end

end
