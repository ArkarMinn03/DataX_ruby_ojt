require_relative "../../forms/events/event_form.rb"
module Events
  class EventUsecase < BaseUsecase
    def initialize(params)
      @params = params
      @form = Events::EventForm.new(params)
    end

    def create
      begin
        if @form.valid?
          event_create_service = Events::EventService.new(@form.attributes)
          response = event_create_service.create
          if response[:status] == :created
            return { event: response[:event], status: :created }
          end
        else
          @event = Event.new(@form.attributes)
          return { event: @event, errors: @form.errors, status: :unprocessable_entity }
        end
      rescue StandardError => errors
        return { event: @event, errors: errors.message, status: :unprocessable_entity }
      end
    end
  end
end