Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # The root is a redirect to the orders index
  root to: "orders#index" # VIEW
  get "financial/report", to: "orders#financialReport" # VIEW
  
  # orders routes
  get "order", to: "orders#index" # for see all orders 
  get "orders", to: "orders#showAll" # for see all orders 
  get "order/:id", to: "orders#show" # for see one order 
  # Create a new Order
  post "order", to: "orders#create" # for create a new order
  # Get the status of an Order
  get "order/search/status/name", to: "orders#showStatusByName" # get id and status for your orders (were not sent yet) by your name
  # List the Orders of a Purchase Channel
  get "order/search/purchasechannel", to: "orders#showListByPurchaseChannel" # get all orders from a Purchase Channel
  # A simple financial report
  get "reports", to: "orders#reports" # get a little and simple financial report for all order is not sent yet

  #batches routes
  get "batch", to: "batches#index" # for see all batches 
  get "batches", to: "batches#showAll" # for see all batches 
  # Create a Batch
  post "batch", to: "batches#create" # for create a new batch
  # Produce a Batch
  get "batch/produce", to: "batches#produce" # for create a new batch
  # Close part of a Batch for a Delivery Service
  get "batch/close", to: "batches#close" # for create a new batch

end
