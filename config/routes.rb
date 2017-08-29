Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks", registrations: "registrations"  }

  mount ActionCable.server => '/cable'

  resources :users
  resources :books, only: [:create, :show]

  root to: 'pages#index'
end
