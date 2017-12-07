Rails.application.routes.draw do

  get 'competitors/index'

  resources :queries do
    resources :competitors, only: [:index]
  end

  root to: 'queries#new'
  get "/competition", to: "pages#competition"
  get "/insee/:zoom/:lat/:long", to: "pages#insee" , :constraints => { :lat => /[^\/]+/, :long => /[^\/]+/ }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
