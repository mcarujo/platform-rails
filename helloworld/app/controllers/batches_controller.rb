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
        # get all orders from this purchase channel
        AllOrders = Order.select("deliveryService as ds, group_concat(reference) as refs").where(purchaseChannel: purchaseChannel, status: 'ready').group('deliveryService')

        if AllOrders.size == 0 || AllOrders == []
            return render json: {message:"Has no order to create a batch for '#{purchaseChannel}''", data: false}, status: :ok
        end

        ## for every deliveryService will be create a new batch
        AllOrders.each do |ordersByDelivery|
            batch = Batch.new
            batch.reference = definePKBatches()
            batch.purchaseChannel = purchaseChannel
            ordersLocal = ordersByDelivery.refs.split(',') # take all orders by delivery service like a Array
            ordersReferences = []
            ordersLocal.each do |order|
                order = Order.find_by(reference: orderLocal)
                order.status = 'production'
                ordersReferences << order.reference
                order.save
            end
            batch.orders = ordersReferences.to_json
            if batch.save
                batches << {reference: batch.reference, numOrders: ordersLocal.size}
            end
        end

        if batches.size != 0 || batches == []
            json = {message:'Batch(es) created', data: batches }
        else
            json = {message: "For some reason, we can't create your batch, please contact us", data: false}
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
        deliveryService = params[:deliveryService]
        batch = Batch.find_by(reference: params[:reference])
        if batch == nil # did I found something?
            return render json: {message:'No batch found', data: false}, status: :ok
        end
        orders = JSON.parse(batch.orders.to_s)
        order_references = []
        orders.each do |reference|
            order = Order.find_by(reference: reference)
            if order.deliveryService == deliveryService && order.status == 'closing'
                order.status = 'sent'
                order.save
                order_references << order.reference
            end
        end
        render json: {message:'Batch closed and returned orders references', data: order_references}, status: :ok  
    end

end
