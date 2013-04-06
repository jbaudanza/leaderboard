Leaderboard::Application.routes.draw do
  root :to => 'leaderboards#show'
  
  resources :identities
end
