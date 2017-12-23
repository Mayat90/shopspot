Rails.application.routes.draw do

  devise_for :users
  resources :queries do
    resources :competitors, only: [:index]
    resources :cities, only: [:index]
  end
  root to: 'queries#new'

  resources :tiles, only: :index

  get "/about" => "pages#about"

  get "/queries/:zoom/:lat/:long", to: "queries#population" , :constraints => { :lat => /[^\/]+/, :long => /[^\/]+/ }
  get "/insee/:zoom/:lat/:long", to: "pages#insee" , :constraints => { :lat => /[^\/]+/, :long => /[^\/]+/ }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
