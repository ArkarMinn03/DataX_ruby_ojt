class CsvService
  def initialize (params)
    @params = params
  end

  def self.import(records)
    Event.import(records, recursive: true)
  end

  def to_model
    event = Event.new(@params.except(:guest_ids))
    event.combine_date_time

    # create_google_events(event, @params[:guest_ids])

    return event
  end

  def add_guests_records(guest_records, event, guest_ids)
    guest_ids.each do |guest_id|
      if guest_id != "" && User.find(guest_id).google_token.present?
        google_event_id = create_google_event(event, guest_id)
      else
        google_event_id = nil
      end
      guest_records << { user_id: guest_id, event: event, google_event_id: google_event_id }
    end
  end

  def create_google_event(event, guest_id)
    calendar_create_service = GoogleCalendarService.new(guest_id)
    google_event = calendar_create_service.create_event(event)

    return google_event.id
  end
end