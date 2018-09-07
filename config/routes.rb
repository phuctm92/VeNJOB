Rails.application.routes.draw do
  root 'home#index'
  get "/cities", to: "cities#index"
  get "/industries", to: "industries#index"
end
