Leaderboard::Application.routes.draw do
  root :to => 'leaderboards#show'
  
  resources :identities do
    post :refresh, :on => :member
  end
  resources :qr_codes
end
