module Api
  module V1
    class UserInvitationsController < BaseController
      before_action :authenticate_user!, except: [:validate, :accept]
      before_action :ensure_admin!, except: [:accept, :resend, :validate]
      before_action :set_invitation, only: [:show, :resend, :cancel]

      # GET /api/v1/user_invitations
      def index
        invitations = Current.tenant.user_invitations.includes(:invited_by)
        
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

      # GET /api/v1/users/invitations/validate/:token
      def validate
        invitation = UserInvitation.find_by(token: params[:token])
        
        if invitation.nil?
          render json: { error: 'Invalid invitation token' }, status: :not_found
          return
        end
        
        if invitation.expired?
          render json: { error: 'Invitation has expired' }, status: :unprocessable_entity
          return
        end
        
        if invitation.status != 'pending'
          render json: { error: "Invitation has already been #{invitation.status}" }, status: :unprocessable_entity
          return
        end
        
        render json: {
          invitation: {
            id: invitation.id,
            email: invitation.email,
            role: invitation.role,
            status: invitation.status,
            expires_at: invitation.expires_at,
            message: invitation.message,
            tenant: {
              name: invitation.tenant.name,
              slug: invitation.tenant.slug
            }
          }
        }
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
      # Generate first_name and last_name from email if not provided
      email_parts = invitation_params[:email].split('@').first.split(/[._-]/)
      first_name = invitation_params[:first_name] || email_parts.first&.capitalize || 'User'
      last_name = invitation_params[:last_name] || email_parts.last&.capitalize || 'User'
      
      user = Current.tenant.users.build(
        username: generate_username(invitation_params[:email]),
        email: invitation_params[:email],
        first_name: first_name,
        last_name: last_name,
        role: invitation_params[:role] || 'user',
        active: false,
        password: (temp_password = SecureRandom.hex(12)), # Generate a temporary password
        password_confirmation: temp_password
      )

      if user.save
        invitation = Current.tenant.user_invitations.create!(
          email: user.email,
          invited_by: current_user,
          role: invitation_params[:role] || 'user',
          message: invitation_params[:message]
        )

                            # Send invitation email
                  UserInvitationMailer.invitation_email(invitation).deliver_later

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

        # Send invitation reminder email
        UserInvitationMailer.invitation_reminder(@invitation).deliver_later

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

      # POST /api/v1/users/invitations/accept/:token
      def accept
        invitation = UserInvitation.find_by(token: params[:token])
        
        if invitation.nil?
          render json: { error: 'Invalid invitation token' }, status: :not_found
          return
        end
        
        if invitation.expired?
          render json: { error: 'Invitation has expired' }, status: :unprocessable_entity
          return
        end
        
        if invitation.status != 'pending'
          render json: { error: "Invitation has already been #{invitation.status}" }, status: :unprocessable_entity
          return
        end
        
        # Create the user account
        user = User.new(
          email: invitation.email,
          username: accept_params[:username],
          first_name: accept_params[:first_name],
          last_name: accept_params[:last_name],
          password: accept_params[:password],
          password_confirmation: accept_params[:password],
          role: invitation.role,
          tenant: invitation.tenant,
          active: true
        )
        
        if user.save
          # Mark invitation as accepted
          invitation.update(
            status: 'accepted',
            used_at: Time.current
          )
          
          render json: {
            user: {
              id: user.id,
              email: user.email,
              username: user.username,
              first_name: user.first_name,
              last_name: user.last_name,
              role: user.role
            },
            message: 'Account created successfully'
          }, status: :created
        else
          render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
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
        params.permit(:email, :first_name, :last_name, :role, :message)
      end

      def accept_params
        params.require(:user).permit(:username, :first_name, :last_name, :password)
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
          user_id: invitation.user&.id,
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
