Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # The root is a redirect to the orders index
  root to: "orders#index"

  # orders routes
  get "order", to: "orders#showAll" # for see all orders 
  get "orders", to: "orders#index" # for see all orders 
  get "order/:id", to: "orders#show" # for see one order 
  get "order/search/status/name", to: "orders#showStatusByName" # get id and status for your orders (were not sent yet) by your name
  get "order/search/purchasechannel", to: "orders#showListByPurchaseChannel" # get all orders from a Purchase Channel
  post "order", to: "orders#create" # for create a new order
  get "financial/report", to: "orders#financialReport" # get a little and simple financial report for all order is not sent yet


  #batches routes
  get "batch", to: "batches#index" # for see all batches 
  get "batch/:id", to: "batches#show" # for see all batches 
  get "batch/produce/:id", to: "batches#produce" # for create a new batch
  post "batch", to: "batches#create" # for create a new batch

end
