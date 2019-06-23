require 'json'
class BatchesController < ApplicationController

    def show
        render json: {message:'Batch information', data: Batch.find_by(reference: params[:reference])}, status: :ok
    end

    def showAll
        render json: {message:'Batchs list', data: Batch.all}, status: :ok
    end

    def create # Create a Batch
        postFields = params.permit(:reference, :purchaseChannel, :orders)
        if !JSON.parse(params[:orders]) # Validation orders as json
            return render json: {message:'The field orders must be a valid JSON', data: false}, status: :ok
        end
        batch = Batch.new postFields
        if batch.save
            json = {message:'Batch created', data: {reference: batch.reference, numOrders: '10'}}
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
