class OrdersController < ApplicationController
    def index
        orders = Order.all
        render json: {status: 'SUCCESS', message:'Orders list', data:orders},status: :ok
    end
    def show
        order = Order.find(params[:id])
        render json: {status: 'SUCCESS', message:'Order information', data:order},status: :ok
    end
    def create
        postFields = params.permit(:reference, :purchaseChannel, :clientName, :address, :deliveryService, :totalValue, :lineItems, :status)
        id = Order.create postFields
        render json: {status: 'SUCCESS', message:'Orders created', data:id.id}, status: :ok
    end
end
