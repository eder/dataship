module Api
  class ProductsController < ApplicationController
    def index
      page     = params.fetch(:page, 1).to_i
      per_page = params.fetch(:per_page, 10).to_i
      offset   = (page - 1) * per_page

      products       = ProductFilter.new(params).call
      total_results  = products.count
      paginated      = products.offset(offset).limit(per_page)
      
      render json: {
        meta: {
          current_page:  page,
          per_page:      per_page,
          total_results: total_results
        },
        products: ActiveModelSerializers::SerializableResource.new(
          paginated, each_serializer: ProductSerializer
        )
      }
    end
    # Receives a CSV file, stores it in a persistent directory, and enqueues a job for processing.
    def upload
      if params[:file].present?
        file = params[:file]

        uploads_dir = Rails.root.join('tmp', 'uploads')
        FileUtils.mkdir_p(uploads_dir) unless Dir.exist?(uploads_dir)

        filename = "#{Time.now.to_i}_#{file.original_filename}"
        filepath = uploads_dir.join(filename)

        File.open(filepath, 'wb') do |f|
          f.write(file.read)
        end

        CsvProcessingJob.perform_later(filepath.to_s)
        Rails.logger.info("Enqueued CSV processing job for file: #{filepath}")

        render json: { message: "File is being processed" }, status: :accepted
      else
        render json: { error: "No file provided" }, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error("Error in upload action: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      render json: { error: "An error occurred while uploading the file" }, status: :internal_server_error
    end
  end
end

