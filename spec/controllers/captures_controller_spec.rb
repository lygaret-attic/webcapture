require 'rails_helper'

RSpec.describe API::CapturesController, type: :controller do
  include APISpec

  let_suite_model(:user)  { create(:user_with_stuff, count: 5) }
  let_suite_model(:chaff) { create(:user_with_stuff, count: 5) }

  context "authenticated" do
    before(:each) { session_auth(@user) }

    context "#index" do
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

      it "show pending by default" do
        @user.captures.first.merged!

        get :index, format: :json
        json = JSON.parse(response.body)
        expect(json.length).to eq(4)
      end

      it "show pending for garbage status" do
        @user.captures.first.merged!

        get :index, format: :json, status: "WHATWHYWHOWHEREWHEN"
        expect(response).to have_http_status 200
        json = JSON.parse(response.body)
        expect(json.length).to eq(4)
      end

      it "show pending for empty status" do
        @user.captures.first.merged!

        get :index, format: :json, status: ""
        expect(response).to have_http_status 200
        json = JSON.parse(response.body)
        expect(json.length).to eq(4)
      end

      it "can show merged only" do
        @user.captures.first.merged!

        get :index, format: :json, status: "merged"
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
      end

      it "can show all" do
        @user.captures.first.merged!

        get :index, format: :json, status: "all"
        json = JSON.parse(response.body)
        expect(json.length).to eq(5)
      end
    end

    context "#show" do
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

    context "#create" do
      it "responds to json" do
        post :create, capture: { content: "* Some Text" }, format: :json

        expect(response.status).to eq(201)
        expect(response.content_type).to eq("application/json")

        json = JSON.parse(response.body)
        expect(json["key"]).to be_present
        expect(json["content"]).to eq(["* Some Text",
                                       "  :PROPERTIES:",
                                       "  :webcapture: #{json["key"]}",
                                       "  :END:"].join("\n"))
      end

      it "responds to org" do
        post :create, capture: { content: "* Some Text" }, format: :org

        expect(response.status).to eq(201)
        expect(response.content_type).to eq("text/x-org")
        expect(response.body).to be_present
      end
    end

    context "#destroy" do
      let(:capture) { @user.captures.pending.first }

      it "marks as merged, by default" do
        delete :destroy, id: capture.key

        capture.reload
        expect(capture).to be_merged
      end

      it "deletes if forced" do
        delete :destroy, id: capture.key, force: true
        expect(Capture.find_by id: capture.id).to be_nil
      end
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

    it "#create" do
      post :create
      expect(response).to have_http_status(:forbidden)
    end

    it "#update" do
      delete :destroy, id: "someid"
      expect(response).to have_http_status(:forbidden)
    end
  end
end
