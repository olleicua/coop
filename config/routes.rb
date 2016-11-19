Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'
  resources :games, except: :destroy do
    patch :join
    patch :move
    get :poll
  end
end
