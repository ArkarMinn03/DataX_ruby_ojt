class User < ApplicationRecord
  has_one_attached :profile
  has_many :event_guests, dependent: :destroy
  # has_many :events, through: :event_guests

  def image_url
    Rails.application.routes.url_helpers.url_for(profile) if profile.attached?
  end

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end

  def google_token_expired?
    expired_at < Time.current
  end
end
