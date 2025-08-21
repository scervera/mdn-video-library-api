module Api
  module V1
    class AuthController < BaseController
      before_action :authenticate_user!, only: [:me, :logout]

      def login
        # Try to find user by username or email
        user = ::User.find_by(username: params[:username]) || ::User.find_by(email: params[:email])
        
        if user&.valid_password?(params[:password])
          user.update!(last_login_at: Time.current)
          token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
          
          user_data = {
            id: user.id,
            username: user.username,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            full_name: user.full_name,
            role: user.role,
            active: user.active
          }
          
          meta = {
            token: token
          }
          
          render_single_response(user_data, meta: meta)
        else
          render_unauthorized_error('Invalid credentials')
        end
      end

      def logout
        # In a real app, you might want to blacklist the token
        render_action_response(message: 'Logged out successfully')
      end

      def me
        user_data = {
          id: current_user.id,
          username: current_user.username,
          email: current_user.email,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          full_name: current_user.full_name,
          role: current_user.role,
          active: current_user.active
        }
        
        render_single_response(user_data)
      end

      def register
        user = ::User.new(user_params)
        
        if user.save
          token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
          
          user_data = {
            id: user.id,
            username: user.username,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            full_name: user.full_name,
            role: user.role,
            active: user.active
          }
          
          meta = {
            token: token
          }
          
          render_single_response(user_data, meta: meta, status: :created)
        else
          render_validation_errors(user)
        end
      end

      private

      def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name)
      end
    end
  end
end
