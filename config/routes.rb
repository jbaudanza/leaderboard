Leaderboard::Application.routes.draw do
  root :to => 'leaderboards#show'
  
  resources :identities do
    post :refresh, :on => :member
  end
  resources :qr_codes
  
  # www.bitcoinleaderboard.com/mattmatt
  get '/:name', :to => 'leaderboards#show', :as => 'name'
  
  
  get '/auth/twitter/callback', to: 'sessions#create', as: 'callback'
  get '/auth/failure', to: 'sessions#error', as: 'failure'
  delete '/signout', to: 'sessions#destroy', as: 'signout'
end
