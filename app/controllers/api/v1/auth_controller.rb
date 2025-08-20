module Api
  module V1
    class AuthController < BaseController
      before_action :authenticate_user!, only: [:me, :logout]

      def login
        # Try to find user by username or email
        user = ::User.find_by(username: params[:username]) || ::User.find_by(email: params[:email])
        
        if user&.valid_password?(params[:password])
          token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
          render json: { 
            user: {
              id: user.id,
              username: user.username,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name,
              full_name: user.full_name,
              role: user.role,
              active: user.active
            }, 
            token: token 
          }
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      def logout
        # In a real app, you might want to blacklist the token
        render json: { message: 'Logged out successfully' }
      end

      def me
        render json: {
          id: current_user.id,
          username: current_user.username,
          email: current_user.email,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          full_name: current_user.full_name,
          role: current_user.role,
          active: current_user.active
        }
      end

      def register
        user = ::User.new(user_params)
        
        if user.save
          token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
          render json: { 
            user: {
              id: user.id,
              username: user.username,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name,
              full_name: user.full_name,
              role: user.role,
              active: user.active
            }, 
            token: token 
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name)
      end
    end
  end
end
