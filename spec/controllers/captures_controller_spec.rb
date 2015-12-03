require 'rails_helper'

RSpec.describe API::CapturesController, type: :controller do
  include APISpec

  let_suite_model(:user)  { create(:user_with_captures, count: 5) }
  let_suite_model(:chaff) { create(:user_with_captures, count: 5) }

  context "authenticated" do
    before(:each) { session_auth(@user) }

    it "#index.json gives the full list of pending captures by @user" do
      get :index, format: :json
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq "application/json"

      json = JSON.parse(response.body)
      expect(json.length).to eq(5)
    end

    it "#index.org gives something in text/x-org" do
      get :index, format: :org
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq "text/x-org"
    end

    it "#index.{other} gives 406" do
      get :index, format: :html
      expect(response).to have_http_status(406)
    end

    let(:capture) { @user.captures.pending.first }

    it "#show/{key}.json, gives a single capture" do
      get :show, id: capture.key, format: :json
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq("application/json")

      json = JSON.parse(response.body)
      expect(json["key"]).to eq(capture.key)
    end

    it "#show/{key}.org, gives a single capture ind text/x-org" do
      get :show, id: capture.key, format: :org
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq("text/x-org")
    end

    it "#show/{key}.{other}, gives 406" do
      get :show, id: capture.key, format: :html
      expect(response).to have_http_status(406)
    end
  end

  context "requires authentication" do
    it "#index" do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it "#show" do
      get :show, id: "someid"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "requires capture scope" do
    before(:each) {
      session[:user_id] = @user.id
      session[:scopes]  = ["not good enough"]
    }

    it "#index" do
      get :index
      expect(response).to have_http_status(:forbidden)
    end

    it "#show" do
      get :show, id: "someid"
      expect(response).to have_http_status(:forbidden)
    end
  end

end
