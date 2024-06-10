module Events
  class EventService
    def initialize(params)
      @params = params
    end

    def create
      event = Event.new(@params.except(:guest_ids))
      if event.save
        add_guests(event)
        return { event: event, status: :created }
      else
        return { event: event, status: :unprocessable_entity }
      end
    end

    def update(update_event)
      if update_event.update(@params.except(:guest_ids))
        update_guests(update_event, @params[:guest_ids])
        return { event: update_event, status: :updated }
      else
        return { event: update_event, status: :unprocessable_entity }
      end
    end

    def destroy(delete_event)
      event = Event.find(delete_event[:id])
      if event.destroy
        return true
      else
        return false
      end
    end

    private
      def add_guests(event)
        event_guests = @params[:guest_ids].map do |guest_id|
          event.event_guests.new(user_id: guest_id)
        end

        EventGuest.import(event_guests)
      end

      def update_guests(event, guest_ids)
        current_guest_ids = event.event_guests.pluck(:user_id)
        event.event_guests.where.not(user_id: guest_ids).delete_all
        new_guest_ids = guest_ids - current_guest_ids.map(&:to_s)
        event_guests = new_guest_ids.map do |guest_id|
          event.event_guests.new(user_id: guest_id)
        end

        EventGuest.import(event_guests)
      end
  end
end