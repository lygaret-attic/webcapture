Rails.application.routes.draw do
  namespace :api, defaults: { format: "json" } do
    scope :v1 do
      resource :user, only: [:show, :update] do
        post :authenticate
      end

      resources :captures, except: [:new, :edit]
    end
  end
end
