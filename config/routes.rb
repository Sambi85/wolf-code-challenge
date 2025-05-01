Rails.application.routes.draw do
  resources :opportunities, only: [ :index, :create ] do
    post "apply", on: :member
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
