class UserInvitationMailer < ApplicationMailer
  def invitation_email(invitation)
    @invitation = invitation
    @user = invitation.user
    @tenant = invitation.tenant
    @invited_by = invitation.invited_by
    @accept_url = generate_accept_url(invitation)
    
    mail(
      to: @invitation.email,
      subject: "You've been invited to join #{@tenant.name}"
    )
  end

  def invitation_reminder(invitation)
    @invitation = invitation
    @user = invitation.user
    @tenant = invitation.tenant
    @invited_by = invitation.invited_by
    @accept_url = generate_accept_url(invitation)
    
    mail(
      to: @invitation.email,
      subject: "Reminder: Complete your invitation to #{@tenant.name}"
    )
  end

  private

  def generate_accept_url(invitation)
    # This should point to the frontend invitation acceptance page
    # The frontend will handle the token validation and user activation
    base_url = Rails.env.production? ? "https://curriculum.cerveras.com" : "http://localhost:3000"
    "#{base_url}/#{invitation.tenant.slug}/invite/#{invitation.token}"
  end
end
