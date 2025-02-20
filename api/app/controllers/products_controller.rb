module Api
  class ProductsController < ApplicationController
    def upload
      if params[:file].present?
        CsvProcessingJob.perform_later(params[:file].path)
        render json: { message: 'File is being processed' }, status: :accepted
      else
        render json: { error: 'No file provided' }, status: :unprocessable_entity
      end
    end

    def index
      products = Product.all
      products = products.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
      products = products.where("price >= ?", params[:min_price]) if params[:min_price].present?
      products = products.where("price <= ?", params[:max_price]) if params[:max_price].present?
      if params[:sort].present? && %w[name price expiration].include?(params[:sort])
        order = params[:order] == 'desc' ? :desc : :asc
        products = products.order(params[:sort] => order)
      end
      render json: products, status: :ok
    end
  end
end

