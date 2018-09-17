Rails.application.routes.draw do
  root 'home#index'
  get "/cities", to: "cities#index"
  get "/industries", to: "industries#index"

  resources :jobs, only: [:index] do
    collection do
      get 'city/:id', to:"jobs#city", as:"city"
      get 'industry/:id', to:"jobs#industry", as:"industry"
      get 'company/:id', to:"jobs#company", as:"company"
    end
  end

  get '/detail/:id', to: "jobs#show", as: 'detail'
end
