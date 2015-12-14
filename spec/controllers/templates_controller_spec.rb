require 'rails_helper'

RSpec.describe API::TemplatesController, type: :controller do
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

      it "#index.{other} gives 406" do
        get :index, format: :html
        expect(response).to have_http_status(406)
      end
    end

    context "#show" do
      let(:template) { @user.templates.first }

      it "#show/{key}.json, gives a single capture" do
        get :show, id: template.key, format: :json
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq("application/json")

        json = JSON.parse(response.body)
        expect(json["key"]).to eq(template.key)
      end

      it "#show/{key}.{other}, gives 406" do
        get :show, id: template.key, format: :html
        expect(response).to have_http_status(406)
      end
    end

    context "#create" do
      it "responds to json" do
        post :create, template: { template: "* TODO %?", properties: { foo: "bar", xy: "zzy" }}, format: :json

        expect(response.status).to eq(201)
        expect(response.content_type).to eq("application/json")

        json = JSON.parse(response.body)
        expect(json["key"]).to be_present
        expect(json["template"]).to eq("* TODO %?")
        expect(json["properties"]).to contain_exactly(["foo", "bar"], ["xy", "zzy"])
      end
    end

    context "#update" do
      let(:template) {
        @user.templates.create! template: "old template", properties: { old: "value" }
      }

      it "can update the template independently" do
        put :update, id: template.key, template: { template: "new template" }

        template.reload
        expect(template.template).to eq("new template")
        expect(template.properties.key? "old").to be true
        expect(template.properties.length).to eq(1)
      end

      it "can update properties independently" do
        put :update, id: template.key, template: { properties: { old: "__delete", new: "deal" }}

        template.reload
        expect(template.template).to eq("old template")
        expect(template.properties.keys).to contain_exactly("new")
        expect(template.properties["new"]).to eq("deal")
      end
    end

    context "#destroy" do
      it "destroys the given template" do
        template = @user.templates.first
        delete :destroy, id: template.key

        expect(response).to have_http_status(200)
        expect(Template.find_by key: template.key).to be_nil
      end
    end
  end

  context "requires template scope" do
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
      patch :update, id: "someid"
      expect(response).to have_http_status(:forbidden)
    end

    it "#update" do
      delete :destroy, id: "someid"
      expect(response).to have_http_status(:forbidden)
    end
  end
end
