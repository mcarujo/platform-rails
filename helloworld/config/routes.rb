Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # The root is a redirect to the orders index
  root to: "orders#index"

  # orders routes
  get "order", to: "orders#index" # for see all orders 
  get "order/:id", to: "orders#show" # for see all orders 
  post "order", to: "orders#create" # for create a new order

  #batches routes
  get "batch", to: "batches#index" # for see all batches 
  get "batch/:id", to: "batches#show" # for see all batches 
  post "batch", to: "batches#create" # for create a new batch

end
