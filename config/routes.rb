Rails.application.routes.draw do
  root 'home#index'
  get "/cities", to: "cities#index"
end
