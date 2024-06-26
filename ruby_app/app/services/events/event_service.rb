module Events
  class EventService
    def initialize(params)
      @params = params
    end

    def create
      event = Event.new(@params.except(:guest_ids))
      if event.save
        create_google_events(event, @params[:guest_ids])
        return { event: event, status: :created }
      else
        return { event: event, status: :unprocessable_entity }
      end
    end

    def update(update_event)
      if update_event.update(@params.except(:guest_ids))
        update_google_events(update_event, @params[:guest_ids])
        return { event: update_event, status: :updated }
      else
        return { event: update_event, status: :unprocessable_entity }
      end
    end

    def destroy(delete_event)
      event = Event.find(delete_event[:id])
      delete_google_event(event)
      if event.destroy
        return true
      else
        return false
      end
    end

    def export_all(events)
      csv_data = CSV.generate(headers: true) do |csv|
        csv << ["ID", "Title", "Description", "Start_time", "End_time", "guests"]
        events.each do |event|
          guest_names = get_guest_names(event)

          csv << [event.id, event.title, event.description, event.start_time.strftime("%Y-%m-%d %H:%M"), event.end_time.strftime("%Y-%m-%d %H:%M"), guest_names]
        end
      end

      return csv_data
    end

    def export(event)
      csv_data = CSV.generate(headers: true) do |csv|
        csv << ["ID", "Title", "Description", "Start_time", "End_time", "guests"]
        guest_names = get_guest_names(event)
        csv << [event.id, event.title, event.description, event.start_time.strftime("%Y-%m-%d %H:%M"), event.end_time.strftime("%Y-%m-%d %H:%M"), guest_names]
      end

      return csv_data
    end

    private
      def create_google_events(event, guest_ids)
        event_guest_ids = guest_ids.map do |guest_id|
          if guest_id != "" && User.find(guest_id).google_token.present?
            calendar_create_service = GoogleCalendarService.new(guest_id)
            google_event = calendar_create_service.create_event(event)
            event.event_guests.new(user_id: guest_id, google_event_id: google_event.id)
          else
            event.event_guests.new(user_id: guest_id, google_event_id: nil)
          end
        end

        EventGuest.import(event_guest_ids)
      end

      def update_google_events(event, guest_ids)
        #retrieving the guests related to the old event.
        old_guest_ids = event.event_guests.pluck(:user_id)

        #Extracting removed guest id from editing event form
        removed_guest_ids = old_guest_ids.map(&:to_s) - guest_ids

        #removing google event of removed guests
        removed_guest_ids.map do |rm_guest_id|
          if rm_guest_id != "" && User.find(rm_guest_id).google_token.present?
            removed_guest = event.event_guests.find_by(user_id: rm_guest_id)

            if removed_guest.google_event_id.present?
              calendar_remove_service = GoogleCalendarService.new(removed_guest.user_id)
              calendar_remove_service.delete_event(removed_guest.google_event_id)
            end
          end
        end

        #deleting the event guests who are not included in updated @params[:guest_ids]
        event.event_guests.where(user_id: removed_guest_ids).delete_all

        #getting the old user ids that are to be updated.
        guest_ids_to_update = event.event_guests.pluck(:user_id)

        #Extracting newly added guest from editing event form
        new_guest_ids = guest_ids - guest_ids_to_update.map(&:to_s)

        #creating newly added guest and google events if there's any
        create_google_events(event, new_guest_ids) unless new_guest_ids.reject(&:blank?).empty?

        #updating the already existed guests and events
        guest_ids_to_update.map do |guest_id|
          if guest_id != "" && User.find(guest_id).google_token.present?
            event_guest = event.event_guests.find_by(user_id: guest_id)

            calendar_update_service = GoogleCalendarService.new(event_guest.user_id)
            google_event = calendar_update_service.update_event(event, event_guest.google_event_id)

            event_guest.update(google_event_id: google_event.id)
          end
        end
      end

      def delete_google_event(event)
        event.event_guests.map do |guest|
          if guest.google_event_id.present?
            calendar_delete_service = GoogleCalendarService.new(guest.user_id)
            calendar_delete_service.delete_event(guest.google_event_id)
          end
        end
      end

      def get_guest_names(event)
        guest_name_array = []

        event.event_guests.each do |guest|
          guest_name_array << guest.user.decorate.full_name
        end

        guest_names = guest_name_array.join(", ")
      end
  end
end