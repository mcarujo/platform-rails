require 'json'
class BatchesController < ApplicationController
    def index
        batchs = Batch.all
        render json: {status: 'SUCCESS', message:'Batchs list', data: batchs},status: :ok
    end
    def show
        batch = Batch.find(params[:id])
        render json: {status: 'SUCCESS', message:'Batch information', data: batch},status: :ok
    end
    def create # Create a Batch
        postFields = params.permit(:reference, :purchaseChannel, :orders)
        id = Batch.create postFields
        render json: {status: 'SUCCESS', message:'Batch created', data: id.id}, status: :ok
    end
    def produce # Produce a Batch
        batch = Batch.find(params[:id])
        orders = JSON.parse(batch.orders)
        order_ids = []
        orders.each do |id|
            order = Order.find(id)
            order.status = 'closing'
            order.save
            order_ids << order.id
        end
        render json: {status: 'SUCCESS', message:'Batch produced', data: order_ids}, status: :ok  
    end
    def close # Close part of a Batch for a Delivery Service
        batch = Batch.find(params[:id])
        orders = JSON.parse(batch.orders)
        order_ids = []
        orders.each do |id|
            order = Order.find(id)
            if order.deliveryService == params[:deliveryService]
                order.status = 'sent'
                order.save
                order_ids << order.id
            end
        end
        render json: {status: 'SUCCESS', message:'Batch sent', data: order_ids}, status: :ok  
    end
end
