module Api
  module V1
    class UserInvitationsController < BaseController
      before_action :authenticate_user!
      before_action :ensure_admin!, except: [:accept, :resend]
      before_action :set_invitation, only: [:show, :resend, :cancel]

      # GET /api/v1/user_invitations
      def index
        invitations = Current.tenant.user_invitations.includes(:user, :invited_by)
        
        # Apply filters
        invitations = invitations.where(status: params[:status]) if params[:status].present?
        invitations = invitations.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?
        
        # Pagination
        page = (params[:page] || 1).to_i
        per_page = [(params[:per_page] || 20).to_i, 100].min
        invitations = invitations.offset((page - 1) * per_page).limit(per_page)
        
        render json: {
          invitations: invitations.map { |inv| invitation_response(inv) },
          pagination: {
            page: page,
            per_page: per_page,
            total: Current.tenant.user_invitations.count,
            total_pages: (Current.tenant.user_invitations.count.to_f / per_page).ceil
          }
        }
      end

      # GET /api/v1/user_invitations/:id
      def show
        render json: { invitation: invitation_response(@invitation) }
      end

      # POST /api/v1/user_invitations
      def create
        # Check if user already exists
        existing_user = Current.tenant.users.find_by(email: invitation_params[:email])
        if existing_user
          render json: { error: "User with this email already exists" }, status: :unprocessable_entity
          return
        end

        # Check if invitation already exists
        existing_invitation = Current.tenant.user_invitations.pending.find_by(email: invitation_params[:email])
        if existing_invitation
          render json: { error: "Invitation already sent to this email" }, status: :unprocessable_entity
          return
        end

              # Create user and invitation
      user = Current.tenant.users.build(
        username: generate_username(invitation_params[:email]),
        email: invitation_params[:email],
        first_name: invitation_params[:first_name],
        last_name: invitation_params[:last_name],
        role: invitation_params[:role] || 'user',
        active: false,
        password: (temp_password = SecureRandom.hex(12)), # Generate a temporary password
        password_confirmation: temp_password
      )

      if user.save
        invitation = Current.tenant.user_invitations.create!(
          email: user.email,
          invited_by: current_user,
          expires_at: 14.days.from_now,
          message: invitation_params[:message]
        )

          # TODO: Send invitation email
          # send_invitation_email(invitation)

          render json: { invitation: invitation_response(invitation) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/user_invitations/:id/resend
      def resend
        if @invitation.status != 'pending'
          render json: { error: "Can only resend pending invitations" }, status: :unprocessable_entity
          return
        end

        if @invitation.expires_at < Time.current
          render json: { error: "Invitation has expired" }, status: :unprocessable_entity
          return
        end

        # TODO: Send invitation email
        # send_invitation_email(@invitation)

        @invitation.update!(resent_at: Time.current, resent_count: @invitation.resent_count + 1)

        render json: { 
          invitation: invitation_response(@invitation),
          message: "Invitation resent successfully"
        }
      end

      # DELETE /api/v1/user_invitations/:id
      def cancel
        if @invitation.status != 'pending'
          render json: { error: "Can only cancel pending invitations" }, status: :unprocessable_entity
          return
        end

        @invitation.update!(status: 'cancelled', cancelled_at: Time.current)
        
        render json: { 
          invitation: invitation_response(@invitation),
          message: "Invitation cancelled successfully"
        }
      end

      # POST /api/v1/user_invitations/accept
      def accept
        token = params[:token]
        invitation = Current.tenant.user_invitations.pending.find_by(token: token)

        unless invitation
          render json: { error: "Invalid or expired invitation token" }, status: :not_found
          return
        end

        if invitation.expires_at < Time.current
          render json: { error: "Invitation has expired" }, status: :unprocessable_entity
          return
        end

        # Update user with password and activate
        user = invitation.user
        if user.nil?
          render json: { error: "User not found for this invitation" }, status: :not_found
          return
        end
        
        user.password = params[:password]
        user.password_confirmation = params[:password_confirmation]
        user.active = true

        if user.save
          invitation.update!(
            status: 'accepted',
            accepted_at: Time.current,
            used_at: Time.current
          )

          # Generate token for immediate login
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
            token: token,
            message: "Account activated successfully"
          }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/user_invitations/statistics
      def statistics
        render json: {
          total_invitations: Current.tenant.user_invitations.count,
          pending_invitations: Current.tenant.user_invitations.pending.count,
          accepted_invitations: Current.tenant.user_invitations.accepted.count,
          expired_invitations: Current.tenant.user_invitations.where('expires_at < ?', Time.current).count,
          cancelled_invitations: Current.tenant.user_invitations.cancelled.count,
          recent_invitations: Current.tenant.user_invitations.where('created_at >= ?', 30.days.ago).count,
          acceptance_rate: calculate_acceptance_rate
        }
      end

      private

      def set_invitation
        @invitation = Current.tenant.user_invitations.find(params[:id])
      end

      def ensure_admin!
        unless current_user.role == 'admin'
          render json: { error: 'Admin access required' }, status: :forbidden
        end
      end

      def invitation_params
        params.require(:invitation).permit(:email, :first_name, :last_name, :role, :message)
      end

      def generate_username(email)
        base_username = email.split('@').first
        username = base_username
        counter = 1

        while Current.tenant.users.exists?(username: username)
          username = "#{base_username}#{counter}"
          counter += 1
        end

        username
      end

      def calculate_acceptance_rate
        total = Current.tenant.user_invitations.count
        accepted = Current.tenant.user_invitations.accepted.count
        
        return 0 if total == 0
        (accepted.to_f / total * 100).round(2)
      end

      def invitation_response(invitation)
        {
          id: invitation.id,
          email: invitation.email,
          user_id: invitation.user_id,
          user: invitation.user ? {
            id: invitation.user.id,
            username: invitation.user.username,
            first_name: invitation.user.first_name,
            last_name: invitation.user.last_name,
            full_name: invitation.user.full_name,
            role: invitation.user.role
          } : nil,
          invited_by: invitation.invited_by ? {
            id: invitation.invited_by.id,
            username: invitation.invited_by.username,
            full_name: invitation.invited_by.full_name
          } : nil,
          status: invitation.status,
          message: invitation.message,
          expires_at: invitation.expires_at,
          created_at: invitation.created_at,
          accepted_at: invitation.accepted_at,
          used_at: invitation.used_at,
          cancelled_at: invitation.cancelled_at,
          resent_at: invitation.resent_at,
          resent_count: invitation.resent_count,
          token: invitation.token
        }
      end
    end
  end
end
