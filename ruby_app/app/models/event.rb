class Event < ApplicationRecord
  has_many :event_guests

  attr_accessor :start_date_part, :start_time_part, :end_date_part, :end_time_part

  before_save :combine_date_time

  def combine_date_time
    if start_date_part.present? && start_time_part.present?
      self.start_time = DateTime.parse("#{ start_date_part } #{ start_time_part }");
    end

    if end_date_part.present? && end_time_part.present?
      self.end_time = DateTime.parse("#{ end_date_part } #{ end_time_part }");
    end
  end
end
