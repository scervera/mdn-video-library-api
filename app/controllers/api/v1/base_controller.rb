module Api
  module V1
    class BaseController < Api::BaseController
      include ApiResponseHelper
      
      # V1-specific functionality can be added here
      # For now, we inherit all functionality from Api::BaseController
    end
  end
end
