module Events
  class EventService
    def initialize(params)
      @params = params
    end

    def create
      event = Event.new(@params)
      if event.save
        return { event: event, status: :created }
      else
        return { event: event, status: :unprocessable_entity }
      end
    end

    def update(update_event)
      if update_event.update(@params)
        return { event: update_event, status: :updated }
      else
        return { event: update_event, status: :unprocessable_entity }
      end
    end

  end
end