class OrdersController < ApplicationController
    include OrdersHelper

    def show
        order = Order.find(params[:id])
        render json: {status: 'SUCCESS', message:'Order information', data:order},status: :ok
    end

    def showAll
        orders = Order.all
        render json: {status: 'SUCCESS', message:'Orders list', data:orders},status: :ok
    end

    def showStatusByName # Get the status of an Order
        orders = Order.where(clientName: params[:name]).where.not(status: "sent")
        if orders.size < 1 or !params[:name]
            returnMessage = "The name '#{params[:name] ? params[:name] : "invalid" }' has none order"
        else
            orders = cutInformationByStatus(orders)
            returnMessage = 'Orders status by name'
        end
        render json: {status: 'SUCCESS', message: returnMessage, data: orders},status: :ok
    end

    def showListByPurchaseChannel # List the Orders of a Purchase Channel
        orders = Order.where(purchaseChannel: params[:purchaseChannel], status: params[:status])
        if orders.size < 1 or !params[:purchaseChannel] or !params[:status]
            returnMessage = "The purchase channel '#{params[:purchaseChannel] ? params[:purchaseChannel] : "invalid"}' has none order with the status '#{params[:status] ? params[:status] : "invalid"}'"
        else
            returnMessage = 'Order information'
        end
        render json: {status: 'SUCCESS', message: returnMessage, data: orders},status: :ok
    end

    def create # Create a new Order
        postFields = params.permit(:reference, :purchaseChannel, :clientName, :address, :deliveryService, :totalValue, :lineItems, :status)
        order = Order.new postFields
        if order.save
            render json: {status: 'SUCCESS', message:'Order created', data:order.id}, status: :ok
        else
            render json: {status: 'SUCCESS', message: order.errors.full_messages, data: false}, status: :ok
        end
    end
    
    def financialReport # Close part of a Batch for a Delivery Service
        report = Order.select("purchaseChannel, count(id) as quantidade, sum(totalValue) as total").where.not(status: 'sents').group('purchaseChannel')
        render json: {status: 'SUCCESS', message:'Financial Report', data: report}, status: :ok  
    end
end
