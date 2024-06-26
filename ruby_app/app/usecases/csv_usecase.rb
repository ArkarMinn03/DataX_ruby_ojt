require_relative "../forms/events/event_form.rb"

class CsvUsecase < BaseUsecase
  def initialize(file)
    @file = file
  end

  def import
    valid_records = []

    if @file
      begin
        CSV.foreach(@file.path, headers: true) do |row|
          params = set_params(row.to_hash)
          form = Events::EventForm.new(params)

          if form.valid?
            valid_records << form.attributes
          end
        end

        csv_service = CsvService.new(valid_records)
        csv_service.import

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