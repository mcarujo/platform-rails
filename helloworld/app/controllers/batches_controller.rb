class BatchesController < ApplicationController
    def index
        batchs = Batch.all
        render json: {status: 'SUCCESS', message:'Batchs list', data: batchs},status: :ok
    end
    def show
        batch = Batch.find(params[:id])
        render json: {status: 'SUCCESS', message:'Batch information', data: batch},status: :ok
    end
    def create
        postFields = params.permit(:reference, :purchaseChannel, :orders)
        id = Batch.create postFields
        render json: {status: 'SUCCESS', message:'Batch created', data: id.id}, status: :ok
    end
end
