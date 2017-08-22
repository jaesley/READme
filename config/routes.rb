Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks", registrations: "registrations"  }
  root to: "users#show"
end
