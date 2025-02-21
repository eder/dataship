module Api
  class ProductsController < ApplicationController
    def index
      products = Product.all
      products = products.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
      products = products.where("price >= ?", params[:min_price]) if params[:min_price].present?
      products = products.where("price <= ?", params[:max_price]) if params[:max_price].present?

      if params[:sort].present? && %w[name price expiration].include?(params[:sort])
        order = params[:order] == "desc" ? :desc : :asc
        products = products.order(params[:sort] => order)
      end

      render json: products, status: :ok
    end

    def show
      product = Product.find(params[:id])
      render json: product, status: :ok
    end
    def upload
      if params[:file].present?
        file = params[:file]

        # Define o diretório de upload persistente
        uploads_dir = Rails.root.join('tmp', 'uploads')
        FileUtils.mkdir_p(uploads_dir) unless Dir.exist?(uploads_dir)

        # Gera um nome único para evitar colisões
        filename = "#{Time.now.to_i}_#{file.original_filename}"
        filepath = uploads_dir.join(filename)

        # Salva o arquivo de forma persistente
        File.open(filepath, 'wb') do |f|
          f.write(file.read)
        end

        # Enfileira o job passando o caminho persistente
        CsvProcessingJob.perform_later(filepath.to_s)

        render json: { message: "File is being processed" }, status: :accepted
      else
        render json: { error: "No file provided" }, status: :unprocessable_entity
      end
    end
  end
end
