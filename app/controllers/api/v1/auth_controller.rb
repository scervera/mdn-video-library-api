module Api
  module V1
    class AuthController < BaseController
      before_action :authenticate_user!, only: [:me, :logout]
      before_action :set_tenant_context_for_auth, only: [:login, :register]

      def login
        # Find user within the specific tenant from URL path
        user = Current.tenant.users.find_by(username: params[:username]) || 
               Current.tenant.users.find_by(email: params[:email])
        
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
        user = Current.tenant.users.new(user_params)
        
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

      def set_tenant_context_for_auth
        # Extract tenant slug from URL path for auth endpoints
        tenant_slug = request.path.split('/')[1]
        return render json: { error: 'Tenant slug required in URL path' }, status: :bad_request unless tenant_slug
        
        tenant = Tenant.find_by(slug: tenant_slug)
        return render json: { error: 'Invalid tenant' }, status: :unauthorized unless tenant
        
        Current.tenant = tenant
      end

      def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name)
      end
    end
  end
end
