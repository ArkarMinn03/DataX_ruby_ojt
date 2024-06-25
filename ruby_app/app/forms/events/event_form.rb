module Events
  class EventForm < BaseForm
    VirtusMixin = Virtus.model
    include VirtusMixin
    include ActiveModel::Validations

    attribute :title, String
    attribute :description, String
    attribute :start_date_part, String
    attribute :start_time_part, String
    attribute :end_date_part, String
    attribute :end_time_part, String
    attribute :guest_ids, Array

    validates :title, presence: { message: "Event title cannot be empty" }
    validates :description, presence: { message: "Event description cannot be empty" }
    validates :start_time, presence: { message: "Start time cannot be empty" }
    validates :end_time, presence: { message: "End time cannot be empty" }
    validate :guest_ids_check
    validate :start_time_check
    validate :end_time_check

    def start_time
      if @start_date_part.present? && @start_time_part.present?
        Time.parse("#{ @start_date_part } #{ @start_time_part }")
      end
    end

    def end_time
      if @end_date_part.present? && @end_time_part.present?
        Time.parse("#{ @end_date_part } #{ @end_time_part }")
      end
    end

    def start_time_check
      if start_time.present? && start_time < Time.current
        errors.add(:start_time, "You cannot make event for the past.")
      end
    end

    def end_time_check
      if end_time.present? && start_time.present?

        time_difference = ((end_time - start_time)/60).minutes
        min_period = 30.minutes

        if time_difference < min_period
          errors.add(:end_time, "An Event must be atleast 30 mins long. ")
        end
      end
    end

    def guest_ids_check
      cleaned_guest_ids = guest_ids.reject(&:blank?)

      if cleaned_guest_ids.empty?
        errors.add(:guest_ids, "There must be atleast one guest!")
      end
    end
  end
end