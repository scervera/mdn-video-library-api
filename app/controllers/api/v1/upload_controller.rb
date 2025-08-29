module Api
  module V1
    class UploadController < BaseController
        def image
    uploaded_image = current_user.uploaded_images.build(
      lesson_id: params[:lesson_id],
      lesson_module_id: params[:module_id]
    )
    uploaded_image.file.attach(params[:file])
    
    if uploaded_image.save
      # Set URL options for Active Storage
      ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 } if Rails.env.development?
      
      render json: {
        success: true,
        image: {
          id: uploaded_image.id,
          url: uploaded_image.url,
          filename: uploaded_image.filename,
          content_type: uploaded_image.content_type,
          byte_size: uploaded_image.byte_size,
          created_at: uploaded_image.created_at
        }
      }
    else
      render json: { 
        success: false, 
        errors: uploaded_image.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
    end
  end
end
