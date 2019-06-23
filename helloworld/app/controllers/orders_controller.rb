class OrdersController < ApplicationController
    include OrdersHelper

    def show
        render json: {message:'Order information', data: Order.find(params[:id])}, status: :ok
    end

    def showAll
        render json: {message:'Orders list', data: Order.all},status: :ok
    end

    def showStatusByName # Get the status of an Order
        if !params.include?(:name) # Validation for name
            return render json: {message: "No field name", data: false},status: :ok
        end
        orders = Order.where(clientName: params[:name]).where.not(status: "sent")
        orders = cutInformationByStatus(orders) # clean the return
        render json: {message: 'Orders status by name', data: orders},status: :ok
    end

    def showListByPurchaseChannel # List the Orders of a Purchase Channel
        if !params.include?(:purchaseChannel) # Validation for Purchase Channel
            json = {message: "No field purchaseChannel", data: false}
        elsif !params.include?(:status) # Validation Status
            json = {message: "No field status", data: false}
        else
            orders = Order.where(purchaseChannel: params[:purchaseChannel], status: params[:status])
            {message: "Orders status by purchase channel and status", data: orders}
        end
        render json: json, status: :ok
    end

    def create # Create a new Order
        postFields = params.permit(:reference, :purchaseChannel, :clientName, :address, :deliveryService, :totalValue, :lineItems, :status)
        order = Order.new postFields
        if order.save
           json = {message:'Order created', data: order.id}
        else
            json = {message: order.errors.full_messages, data: false}
        end
        render json: json, status: :ok
    end
    
    def financialReport # A simple financial report
        report = Order.select("purchaseChannel, count(id) as quantity, sum(totalValue) as total").where.not(status: 'sents').group('purchaseChannel')
        render json: {message:'Financial Report', data: report}, status: :ok  
    end
end
