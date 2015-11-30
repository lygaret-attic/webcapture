Rails.application.routes.draw do
  namespace :api, constraints: { format: 'json' } do
    scope :v1 do
      resource :user, only: [:show, :update] do
        post :authenticate
      end
    end
  end
end
