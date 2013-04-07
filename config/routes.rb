Leaderboard::Application.routes.draw do
  root :to => 'leaderboards#show'
  
  resources :identities
  resources :qr_codes
end
