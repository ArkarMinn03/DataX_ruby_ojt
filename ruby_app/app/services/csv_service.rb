class CsvService
  def initialize (records)
    @records = records
  end

  def import
    event_records = []
    guest_records = []

    @records.each do |record|
      event = to_model(record)
      event_records << event
      add_guests_records(guest_records, event, record[:guest_ids])
    end

    Event.import(event_records, recursive: true)

    imported_events_IDs = Event.where(title: event_records.map(&:title)).group(:title).maximum(:id).values
    imported_events = Event.where(id: imported_events_IDs)

    guest_records.each do |guest_record|
      imported_event = imported_events.find { |e| e.title == guest_record[:event].title }
      guest_record[:event_id] = imported_event.id if imported_event
    end
    EventGuest.import(guest_records.map{ |record| EventGuest.new(record) })
  end

  def to_model(params)
    event = Event.new(params.except(:guest_ids))
    event.combine_date_time

    return event
  end

  def add_guests_records(guest_records, event, guest_ids)
    guest_ids.each do |guest_id|
      if User.exists?(guest_id)
        if User.find(guest_id).google_token.present?
          google_event_id = create_google_event(event, guest_id)
        else
          google_event_id = nil
        end
        guest_records << { user_id: guest_id, event: event, google_event_id: google_event_id }
      end
    end
  end

  def create_google_event(event, guest_id)
    calendar_create_service = GoogleCalendarService.new(guest_id)
    google_event = calendar_create_service.create_event(event)

    return google_event.id
  end
end