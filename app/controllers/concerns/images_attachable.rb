module ImagesAttachable
  extend ActiveSupport::Concern

  included do
    def attached_images_base64
      @attached_images_base64 = []
      images = permit_params[:images]
      unless images.nil?
        images.each do |img|
          @attached_images_base64 << Base64.strict_encode64(img.read)
        end
      end
      @attached_images_base64
    end
  end
end
