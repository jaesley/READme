Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks", registrations: "registrations"  }

  resources :users
  resources :books, only: [:create]

  root to: 'pages#index'
end
