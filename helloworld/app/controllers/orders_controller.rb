class OrdersController < ApplicationController
    include OrdersHelper
    def index
        orders = Order.all
        render json: {status: 'SUCCESS', message:'Orders list', data:orders},status: :ok
    end
    def show
        order = Order.find(params[:id])
        render json: {status: 'SUCCESS', message:'Order information', data:order},status: :ok
    end
    def showStatusByName # Get the status of an Order
        orders = Order.where(clientName: params[:name]).where.not(status: "sent")
        if orders.size < 1
            returnMessage = "The name '#{params[:name]}' has none order"
        else
            orders = cutInformationByStatus(orders)
            returnMessage = 'Orders status by name'
        end
        render json: {status: 'SUCCESS', message: returnMessage, data: orders},status: :ok
    end
    def showListByPurchaseChannel # List the Orders of a Purchase Channel
        orders = Order.where(purchaseChannel: params[:purchaseChannel], status: params[:status])
        if orders.size < 1
            returnMessage = "The purchase channel '#{params[:id]}' has none order with the status '#{params[:status]}'"
        else
            returnMessage = 'Order information'
        end
        render json: {status: 'SUCCESS', message: returnMessage, data: orders},status: :ok
    end
    def create # Create a new Order
        postFields = params.permit(:reference, :purchaseChannel, :clientName, :address, :deliveryService, :totalValue, :lineItems, :status)
        id = Order.create postFields
        render json: {status: 'SUCCESS', message:'Orders created', data:id.id}, status: :ok
    end
    def financialReport # Close part of a Batch for a Delivery Service
        report = Order.select("purchaseChannel, count(id) as quantidade, sum(totalValue) as total").where.not(status: 'sents').group('purchaseChannel')
        render json: {status: 'SUCCESS', message:'Financial Report', data: report}, status: :ok  
    end
end
