module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_user!
      before_action :ensure_admin!, except: [:me, :update_profile]
      before_action :set_user, only: [:show, :update, :destroy, :activate, :deactivate]

      # GET /api/v1/users
      def index
        users = Current.tenant.users.includes(:user_subscriptions)
        
        # Apply filters
        users = users.where(role: params[:role]) if params[:role].present?
        users = users.where("username ILIKE ? OR email ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
        users = users.where(active: params[:active]) if params[:active].present?
        
        # Pagination
        page = (params[:page] || 1).to_i
        per_page = [(params[:per_page] || 20).to_i, 100].min
        users = users.offset((page - 1) * per_page).limit(per_page)
        
        render json: {
          users: users.map { |user| user_response(user) },
          pagination: {
            page: page,
            per_page: per_page,
            total: Current.tenant.users.count,
            total_pages: (Current.tenant.users.count.to_f / per_page).ceil
          }
        }
      end

      # GET /api/v1/users/:id
      def show
        render json: {
          user: user_response(@user),
          statistics: user_statistics(@user)
        }
      end

      # POST /api/v1/users
      def create
        user = Current.tenant.users.build(user_params)
        
        if user.save
          # Send invitation email if email is provided
          if user.email.present?
            UserInvitation.create!(
              tenant: Current.tenant,
              user: user,
              email: user.email,
              invited_by: current_user,
              expires_at: 14.days.from_now
            )
            # TODO: Send invitation email
          end
          
          render json: { user: user_response(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          render json: { user: user_response(@user) }
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        if @user == current_user
          render json: { error: "Cannot delete your own account" }, status: :unprocessable_entity
          return
        end
        
        @user.destroy
        render json: { message: "User deleted successfully" }
      end

      # GET /api/v1/users/me
      def me
        render json: {
          user: user_response(current_user),
          statistics: user_statistics(current_user)
        }
      end

      # PUT /api/v1/users/me
      def update_profile
        if current_user.update(profile_params)
          render json: { user: user_response(current_user) }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/users/:id/activate
      def activate
        @user.update!(active: true)
        render json: { user: user_response(@user) }
      end

      # POST /api/v1/users/:id/deactivate
      def deactivate
        if @user == current_user
          render json: { error: "Cannot deactivate your own account" }, status: :unprocessable_entity
          return
        end
        
        @user.update!(active: false)
        render json: { user: user_response(@user) }
      end

      # GET /api/v1/users/statistics
      def statistics
        render json: {
          total_users: Current.tenant.users.count,
          active_users: Current.tenant.users.where(active: true).count,
          inactive_users: Current.tenant.users.where(active: false).count,
          admin_users: Current.tenant.users.where(role: 'admin').count,
          regular_users: Current.tenant.users.where(role: 'user').count,
          users_with_subscriptions: Current.tenant.users.joins(:user_subscriptions).distinct.count,
          recent_signups: Current.tenant.users.where('created_at >= ?', 30.days.ago).count,
          user_growth: {
            last_7_days: Current.tenant.users.where('created_at >= ?', 7.days.ago).count,
            last_30_days: Current.tenant.users.where('created_at >= ?', 30.days.ago).count,
            last_90_days: Current.tenant.users.where('created_at >= ?', 90.days.ago).count
          }
        }
      end

      private

      def set_user
        @user = Current.tenant.users.find(params[:id])
      end

      def ensure_admin!
        unless current_user.role == 'admin'
          render json: { error: 'Admin access required' }, status: :forbidden
        end
      end

      def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, 
                                   :first_name, :last_name, :role, :active)
      end

      def profile_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
      end

      def user_response(user)
        {
          id: user.id,
          username: user.username,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          full_name: user.full_name,
          role: user.role,
          active: user.active,
          created_at: user.created_at,
          updated_at: user.updated_at,
          last_login_at: user.last_login_at,
          subscription_status: user.user_subscriptions.active.exists? ? 'active' : 'none',
          invitation_status: Current.tenant.user_invitations.pending.where(email: user.email).exists? ? 'pending' : 'accepted'
        }
      end

      def user_statistics(user)
        {
          total_progress_entries: user.user_progresses.count,
          total_notes: user.user_notes.count,
          total_highlights: user.user_highlights.count,
          total_bookmarks: user.bookmarks.count,
          lessons_completed: user.user_progresses.where(completed: true).count,
          time_spent_learning: user.user_progresses.sum(:time_spent),
          last_activity: user.user_progresses.maximum(:updated_at),
          subscription_info: {
            has_active_subscription: user.user_subscriptions.active.exists?,
            subscription_count: user.user_subscriptions.count
          }
        }
      end
    end
  end
end
