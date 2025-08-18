class BrandingController < ApplicationController
  def css
    tenant = Current.tenant
    css_content = generate_css(tenant)

    render plain: css_content, content_type: 'text/css'
  end

  private

  def generate_css(tenant)
    <<~CSS
      :root {
        --primary-color: #{tenant.primary_color};
        --secondary-color: #{tenant.secondary_color};
        --accent-color: #{tenant.accent_color};
      }

      .btn-primary {
        background-color: var(--primary-color);
      }

      .header {
        background-color: var(--secondary-color);
      }

      .accent {
        color: var(--accent-color);
      }
    CSS
  end
end
