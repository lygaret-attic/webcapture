require "rails_helper"

describe API::Authentication, type: :controller do
  controller(ActionController::Base) do
    include API::Authentication

    def unauthenticated
      head status: 204
    end

    def authenticated
      require_user!
      head status: 204
    end

    def authenticate
      initiate_session params["uid"]
      render text: current_user.id, status: 201
    end

    def scoped
      require_scope! :special
      head status: 204
    end
  end

  before do
    routes.draw do
      get ":controller/:action"
      post ":controller/:action"
    end
  end

  context "unauthenticated" do
    it "should allow unauthenticated stuff" do
      get :unauthenticated
      expect(response).to have_http_status(204)
    end

    it "#require_user!" do
      bypass_rescue
      expect { get :authenticated }.to raise_error(API::UnauthorizedError)
    end

    it "#require_scope!" do
      bypass_rescue
      expect { get :scoped }.to raise_error(API::UnauthorizedError)
    end

    it "should allow authenticating a user" do
      user = create(:user, password: "secret")
      post :authenticate, uid: user.id

      expect(response).to have_http_status(201)
      expect(response.body).to eq(user.id.to_s)
      expect(session[:user_id]).to eq(user.id.to_s)
    end
  end

  context "authentication" do
    let(:user) { create(:user, password: "secret") }

    it "should allow authenticating via session" do
      session[:user_id] = user.id

      # should be authenticated,
      # session authentication gets all scopes by default
      get :scoped
      expect(response).to have_http_status(204)
    end

    it "should allow authenticating via basic auth" do
      basic_auth(user.email, "secret")

      # should be authenticated
      # basic authentication gets all scopes by default
      # session should not include user_id, we don't want to get a session for basic auth
      get :scoped
      expect(response).to have_http_status(204)
      expect(session.keys).to be_empty
    end

    xit "should allow authenticating via token" do
      pending "need to implement token auth"
    end
  end

  context "scope" do
    let :user do
      create(:user, password: "secret")
    end

    it "should disallow if missing the named scope" do
      session_auth(user, [:not_special])
      bypass_rescue

      expect { get :scoped }.to raise_error(API::AccessDeniedError)
    end

    it "should allow if I have the named scope" do
      session_auth(user, [:not_special, :special])

      get :scoped
      expect(response).to have_http_status(204)
    end

    it "should allow if I have the :any scope" do
      session_auth(user)

      get :scoped
      expect(response).to have_http_status(204)
    end
  end
end
