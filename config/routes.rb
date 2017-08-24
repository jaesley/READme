Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks", registrations: "registrations"  }

  resources :users

  root to: 'registrations#new'
end
