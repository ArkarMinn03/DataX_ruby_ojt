require_relative "../forms/events/event_form.rb"

class CsvUsecase < BaseUsecase
  def initialize(file)
    @file = file
  end

  def import
    event_records = []
    guests_records = []

    if @file
      begin
        CSV.foreach(@file.path, headers: true) do |row|
          params = set_params(row.to_hash)
          form = Events::EventForm.new(params)

          if form.valid?
            csv_service = CsvService.new(form.attributes)
            event = csv_service.to_model
            event_records << event
            csv_service.add_guests_records(guests_records, event, params[:guest_ids])
          end
        end

        CsvService.import(event_records)

        imported_events_IDs = Event.where(title: event_records.map(&:title)).group(:title).maximum(:id).values

        imported_events = Event.where(id: imported_events_IDs)
        byebug

        guests_records.each do |guest_record|
          imported_event = imported_events.find { |e| e.title == guest_record[:event].title }
          guest_record[:event_id] = imported_event.id if imported_event
        end

        EventGuest.import(guests_records.map{ |record| EventGuest.new(record) })
        return { status: :ok, notice: "Imported success." }
      rescue StandardError => error
        return { errors: error.message, status: :unprocessable_entity }
      end
    end
  end


  private
    def set_params(data)
      title = data["title"]
      description = data["description"]

      start_time = Time.strptime(data["start_time"], "%m/%d/%Y %H:%M")
      start_date_part = start_time.to_date.to_s
      start_time_part = start_time.strftime("%H:%M")

      end_time = Time.strptime(data["end_time"], "%m/%d/%Y %H:%M")
      end_date_part = end_time.to_date.to_s
      end_time_part = end_time.strftime("%H:%M")
      guest_ids = eval(data["guest_ids"])

      params = { title:, description:, start_date_part:, start_time_part:, end_date_part:, end_time_part:, guest_ids: }
    end
end