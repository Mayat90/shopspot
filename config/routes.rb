Rails.application.routes.draw do
  resources :queries
  root to: 'queries#new'

  get "/insee/:zoom/:lat/:long", to: "pages#insee" , :constraints => { :lat => /[^\/]+/, :long => /[^\/]+/ }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
