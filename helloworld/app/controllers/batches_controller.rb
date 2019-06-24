require 'json'
class BatchesController < ApplicationController
    include BatchesHelper
    def show
        render json: definePKBatches()
        # render json: {message:'Batch information', data: Batch.find_by(reference: params[:reference])}, status: :ok
    end

    def showAll
        render json: {message:'Batchs list', data: Batch.all}, status: :ok
    end

    def create # Create a Batch
        if !params.include?(:purchaseChannel) # Validation for name
            return render json: {message: "No field purchaseChannel", data: false},status: :ok
        end

        purchaseChannel = params[:purchaseChannel]
        orders = Order.where(purchaseChannel: purchaseChannel, status: 'ready')

        if orders.size == 0
            return render json: {message:"Has no order to create a batch for '#{purchaseChannel}''", data: false}, status: :ok
        end
        
        batch = Batch.new
        batch.reference = definePKBatches()
        batch.purchaseChannel = purchaseChannel
        
        ordersReferences = []
        orders.each do |order|
            order.status = 'production'
            ordersReferences << order.reference
            order.save
        end
        
        batch.orders = ordersReferences.to_json
        if batch.save
            json = {message:'Batch created', data: {reference: batch.reference, numOrders: orders.size}}
        else
            json = {message: batch.errors.full_messages, data: false}
        end
        render json: json, status: :ok
    end

    def produce # Produce a Batch
        if !params.include?(:reference) # Validation
            return render json: {message:'No field reference', data: false}, status: :ok
        end
        batch = Batch.find_by(reference: params[:reference])
        if batch == nil # did I found something?
            return render json: {message:'No batch found', data: false}, status: :ok
        end
        orders = JSON.parse(batch.orders.to_s)
        order_references = []
        orders.each do |reference|
            order = Order.find_by(reference: reference)
            if order.status == 'production' # if was printed...
                order.status = 'closing' # set already produced (closing)
                order.save
                order_references << order.reference
            end
        end
        render json: {message:'Batch produced and returned orders references', data: order_references}, status: :ok  
    end

    def close # Close part of a Batch for a Delivery Service
        if !params.include?(:reference) # Validation
            return render json: {message:'No field reference', data: false}, status: :ok
        elsif !params.include?(:deliveryService) 
            return render json: {message:'No field deliveryService', data: false}, status: :ok
        end
        devileryService = params[:deliveryService]
        batch = Batch.find_by(reference: params[:reference])
        if batch == nil # did I found something?
            return render json: {message:'No batch found', data: false}, status: :ok
        end
        orders = JSON.parse(batch.orders.to_s)
        order_references = []
        orders.each do |reference|
            order = Order.find_by(reference: reference)
            if order.deliveryService == devileryService && order.status == 'closing'
                order.status = 'sent'
                order.save
                order_references << order.reference
            end
        end
        render json: {message:'Batch closed and returned orders references', data: order_references}, status: :ok  
    end

end
