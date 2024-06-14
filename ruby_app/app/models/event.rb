class Event < ApplicationRecord
  has_many :event_guests, dependent: :destroy
  # has_many :guests, through: :event_guests, source: :user

  attr_accessor :start_date_part, :start_time_part, :end_date_part, :end_time_part

  before_save :combine_date_time
  before_update :combine_date_time

  def combine_date_time
    if start_date_part.present? && start_time_part.present?
      self.start_time = Time.parse("#{ start_date_part } #{ start_time_part }");
    end

    if end_date_part.present? && end_time_part.present?
      self.end_time = Time.parse("#{ end_date_part } #{ end_time_part }");
    end
  end
end
