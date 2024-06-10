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

    def update(update_event)
      begin
        if @form.valid?
          event_update_service = Events::EventService.new(@params)
          response = event_update_service.update(update_event)
          if response[:status] == :updated
            return { event: response[:event], status: :updated }
          end
        else
          @event = Event.new(@form.attributes)
          return { event: @event, errors: @from.errors, status: :unprocessable_entity }
        end
      rescue StandardError => errors
        return { event: @event, errors: errors.message, status: :unprocessable_entity }
      end
    end

    def destroy(delete_event)
      begin
        event_delete_service = Events::EventService.new(@params)
        if event_delete_service.destroy(delete_event)
          return true
        else
          return false
        end
      rescue StandardError => errors
        return false
      end
    end

  end
end