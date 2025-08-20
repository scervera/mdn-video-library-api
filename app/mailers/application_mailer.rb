class ApplicationMailer < ActionMailer::Base
  default from: -> { "#{brevo_config[:from_name]} <#{brevo_config[:from_email]}>" }
  layout "mailer"

  private

  def brevo_config
    @brevo_config ||= Rails.application.config_for(:brevo)
  end
end
