class User < ApplicationRecord
  has_one_attached :profile

  def image_url
    Rails.application.routes.url_helpers.url_for(profile) if profile.attached?
  end
end
