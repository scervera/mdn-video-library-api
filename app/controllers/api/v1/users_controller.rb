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
        
        user_data = users.map { |user| user_response(user) }
        pagination = {
          page: page,
          per_page: per_page,
          total: Current.tenant.users.count,
          total_pages: (Current.tenant.users.count.to_f / per_page).ceil
        }

        render_list_response(user_data, pagination: pagination)
      end

      # GET /api/v1/users/:id
      def show
        user_data = user_response(@user)
        meta = {
          statistics: user_statistics(@user)
        }

        render_single_response(user_data, meta: meta)
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
          
          render_single_response(user_response(user), status: :created)
        else
          render_validation_errors(user)
        end
      end

      # PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          render_single_response(user_response(@user))
        else
          render_validation_errors(@user)
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        if @user == current_user
          render_error_response(
            error_code: 'cannot_delete_self',
            message: "Cannot delete your own account",
            status: :unprocessable_entity
          )
          return
        end
        
        @user.destroy
        render_action_response(message: "User deleted successfully")
      end

      # GET /api/v1/users/me
      def me
        user_data = user_response(current_user)
        meta = {
          statistics: user_statistics(current_user)
        }

        render_single_response(user_data, meta: meta)
      end

      # PUT /api/v1/users/me
      def update_profile
        if current_user.update(profile_params)
          render_single_response(user_response(current_user))
        else
          render_validation_errors(current_user)
        end
      end

      # POST /api/v1/users/:id/activate
      def activate
        @user.update!(active: true)
        render_single_response(user_response(@user))
      end

      # POST /api/v1/users/:id/deactivate
      def deactivate
        if @user == current_user
          render_error_response(
            error_code: 'cannot_deactivate_self',
            message: "Cannot deactivate your own account",
            status: :unprocessable_entity
          )
          return
        end
        
        @user.update!(active: false)
        render_single_response(user_response(@user))
      end

      # GET /api/v1/users/statistics
      def statistics
        statistics_data = {
          # Basic user counts (frontend expected format)
          total_users: Current.tenant.users.count,
          active_users: Current.tenant.users.where(active: true).count,
          pending_invitations: Current.tenant.user_invitations.pending.count,
          admins_count: Current.tenant.users.where(role: 'admin').count,
          users_count: Current.tenant.users.where(role: 'user').count,
          
          # Additional detailed statistics
          inactive_users: Current.tenant.users.where(active: false).count,
          users_with_subscriptions: Current.tenant.users.joins(:user_subscriptions).distinct.count,
          recent_signups: Current.tenant.users.where('created_at >= ?', 30.days.ago).count,
          
          # Invitation statistics
          total_invitations: Current.tenant.user_invitations.count,
          accepted_invitations: Current.tenant.user_invitations.accepted.count,
          expired_invitations: Current.tenant.user_invitations.where('expires_at < ?', Time.current).count,
          cancelled_invitations: Current.tenant.user_invitations.cancelled.count,
          
          # Growth metrics
          user_growth: {
            last_7_days: Current.tenant.users.where('created_at >= ?', 7.days.ago).count,
            last_30_days: Current.tenant.users.where('created_at >= ?', 30.days.ago).count,
            last_90_days: Current.tenant.users.where('created_at >= ?', 90.days.ago).count
          },
          
          # Recent activity
          recent_activity: {
            users_created_last_7_days: Current.tenant.users.where('created_at >= ?', 7.days.ago).count,
            invitations_sent_last_7_days: Current.tenant.user_invitations.where('created_at >= ?', 7.days.ago).count
          }
        }

        render_single_response(statistics_data)
      end

      private

      def set_user
        @user = Current.tenant.users.find(params[:id])
      end

      def ensure_admin!
        unless current_user.role == 'admin'
          render_forbidden_error('Admin access required')
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
          status: user.active ? 'active' : 'inactive',
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
