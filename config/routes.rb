Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  defaults format: :json do
    resources :users, only: [] do
      resources :cars, only: [:index], module: :users
    end
  end
end
