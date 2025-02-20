module Api
  class ProductsController < ApplicationController
    def index
      render json: { message: "Listando produtos" }
    end

    def upload
      render json: { message: "Upload realizado" }
    end
  end
end
