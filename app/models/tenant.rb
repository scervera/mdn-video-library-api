class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :curriculums, dependent: :destroy
  has_many :chapters, dependent: :destroy
  has_many :lessons, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :user_progresses, dependent: :destroy
  has_many :lesson_progresses, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :user_highlights, dependent: :destroy

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }

  # Branding settings
  def branding_settings
    super || default_branding_settings
  end

  def primary_color
    branding_settings['primary_color'] || '#3B82F6'
  end

  def secondary_color
    branding_settings['secondary_color'] || '#1F2937'
  end

  def accent_color
    branding_settings['accent_color'] || '#F59E0B'
  end

  def logo_url
    branding_settings['logo_url']
  end

  def company_name
    branding_settings['company_name'] || name
  end

  def full_domain
    domain.presence || "#{subdomain}.curriculum-library-api.cerveras.com"
  end

  private

  def default_branding_settings
    {
      'primary_color' => '#3B82F6',
      'secondary_color' => '#1F2937',
      'accent_color' => '#F59E0B',
      'company_name' => name
    }
  end
end
