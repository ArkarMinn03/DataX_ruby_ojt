module Events
  class EventForm < BaseForm
    VirtusMixin = Virtus.model
    include VirtusMixin
    include ActiveModel::Validations

    attribute :title, String
    attribute :description, String
    attribute :start_date_part, Date
    attribute :start_time_part, Time
    attribute :end_date_part, Date
    attribute :end_time_part, Time
    attribute :guest_ids, Array

    validates :title, presence: { message: "Event title cannot be empty" }
    validates :description, presence: { message: "Event description cannot be empty" }
    validates :start_time, presence: { message: "Start time cannot be empty" }
    validates :end_time, presence: { message: "End time cannot be empty" }
    validates :guest_ids, presence: { message: "Guest cannot be empty. Must have atleast one guest." }
    validate :start_time_check
    validate :end_time_check
    # validates :end_time_check, presence: { message: "End time Must be after Start time"}

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

        #logic here is that
        #both end_time and start_time are DateTime objects and
        #the difference between than results in "Rational" number
        #so we change it to minutes by multiplying with 1440 mins
        #(1440 mins per day)
        #and change the result to floating point number
        time_difference = ((end_time - start_time)*1440).to_f

        #to change the minutes to floating pont number
        #30.minutes.to_f would directly result the total seconds.
        min_period = 30.minutes.to_f/60

        if time_difference < min_period
          errors.add(:end_time, "End time must be at least 30 minutes after start time. ")
        end
      end
    end
  end
end