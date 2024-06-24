require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:user_id) { "163" }
  let(:test_date) { (DateTime.current().to_date + 2).strftime("%Y-%m-%d") }

  describe "GET /events" do
    it "return all events with status ok" do
      get events_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /events/:id" do
    let(:event) {
      Event.create({
        title: "TESTER",
        description: "testing one two three",
        start_date_part: test_date,
        start_time_part: "03:00",
        end_date_part: test_date,
        end_time_part: "05:00",
        guest_ids: [ "163" ]
      })
    }
    context "when there is an event with that specified id" do
      it "return the specified event" do
        get event_path(event)
        expect(response).to have_http_status(:ok)
      end
    end
    context "when there is no event with that specified id" do
      it "return the specified event" do
        get "/events/#{500}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /events " do
    context "when creating with valid attributes " do
      let(:valid_attributes) {
        {
          event: {
            title: "TESTER",
            description: "testing one two three",
            start_date_part: test_date,
            start_time_part: "07:00",
            end_date_part: test_date,
            end_time_part: "08:00",
            guest_ids: [ "163" ]
          }
        }
      }
      it "creates new event in database" do
        expect{
          post events_path, params: valid_attributes
        }.to change(Event, :count).by(1)
      end

      it "creates new event on google calendar" do
        google_service = GoogleCalendarService.new(163)
        client = google_service.google_client

        initial_list = client.list_events("primary", single_events: true)
        initial_count = initial_list.items.count

        post events_path, params: valid_attributes

        new_list = client.list_events("primary", single_events: true)
        new_count = new_list.items.count

        expect(new_count).to eq(initial_count + 1)
      end

      context "after posting, " do
        before { post events_path, params: valid_attributes }

        it "store google event id in event_guests table" do
          expect(Event.last.event_guests[0].google_event_id).not_to be_nil
        end

        it "redirect to events list" do
          expect(response).to redirect_to(events_path)
          expect(response).to have_http_status(:found)
        end
      end
    end

    context "when creating with invalid attributes, " do
      context "while creating with time period less than 30 minutes " do
        let(:inputs_with_invalid_time_period) {
          {
            event: {
              title: "TESTER",
              description: "testing one two three",
              start_date_part: test_date,
              start_time_part: "07:00",
              end_date_part: test_date,
              end_time_part: "07:25",
              guest_ids: [ "163" ]
            }
          }
        }
        it "does not create new event in database" do
          expect {
            post events_path, params: inputs_with_invalid_time_period
          }.not_to change(Event, :count)
        end

        it "does not create new event on google calendar "do
          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          initial_list = client.list_events("primary")
          initial_count = initial_list.items.count

          post events_path, params: inputs_with_invalid_time_period

          new_list = client.list_events("primary")
          new_count = new_list.items.count

          expect(new_count).to eq(initial_count)
        end

        it "returns error status unprocessable_entity" do
          post events_path, params: inputs_with_invalid_time_period
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "set flash error message" do
          post events_path, params: inputs_with_invalid_time_period
          expect(response.body).to include(I18n.t("messages.common.create_fail", data: "Event"))
        end
      end

      context "while creating without title, " do
        let(:inputs_without_title) {
          {
            event: {
              title: "",
              description: "testing one two three",
              start_date_part: test_date,
              start_time_part: "07:00",
              end_date_part: test_date,
              end_time_part: "08:00",
              guest_ids: [ "163" ]
            }
          }
        }
        it "does not create new event in database" do
          expect {
            post events_path, params: inputs_without_title
          }.not_to change(Event, :count)
        end

        it "does not create new event on google calendar "do
          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          initial_list = client.list_events("primary")
          initial_count = initial_list.items.count

          post events_path, params: inputs_without_title

          new_list = client.list_events("primary")
          new_count = new_list.items.count

          expect(new_count).to eq(initial_count)
        end

        it "returns error status unprocessable_entity" do
          post events_path, params: inputs_without_title
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "set flash error message" do
          post events_path, params: inputs_without_title
          expect(response.body).to include(I18n.t("messages.common.create_fail", data: "Event"))
        end
      end

      context "while creating without end time part" do
        let(:inputs_without_endTimePart) {
          {
            event: {
              title: "TESTER",
              description: "testing one two three",
              start_date_part: test_date,
              start_time_part: "07:00",
              end_date_part: test_date,
              end_time_part: "",
              guest_ids: [ "163" ]
            }
          }
        }
        it "does not create new event in database" do
          expect {
            post events_path, params: inputs_without_endTimePart
          }.not_to change(Event, :count)
        end

        it "does not create new event on google calendar "do
          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          initial_list = client.list_events("primary")
          initial_count = initial_list.items.count

          post events_path, params: inputs_without_endTimePart

          new_list = client.list_events("primary")
          new_count = new_list.items.count

          expect(new_count).to eq(initial_count)
        end

        it "returns error status unprocessable_entity" do
          post events_path, params: inputs_without_endTimePart
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "set flash error message" do
          post events_path, params: inputs_without_endTimePart
          expect(response.body).to include(I18n.t("messages.common.create_fail", data: "Event"))
        end
      end

      context "while creating without multiple missing data" do
        let(:inputs_without_multiple_data) {
          {
            event: {
              title: "",
              description: "testing one two three",
              start_date_part: test_date,
              start_time_part: "07:00",
              end_date_part: "",
              end_time_part: "",
              guest_ids: []
            }
          }
        }
        it "does not create new event in database" do
          expect {
            post events_path, params: inputs_without_multiple_data
          }.not_to change(Event, :count)
        end

        it "does not create new event on google calendar "do
          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          initial_list = client.list_events("primary")
          initial_count = initial_list.items.count

          post events_path, params: inputs_without_multiple_data

          new_list = client.list_events("primary")
          new_count = new_list.items.count

          expect(new_count).to eq(initial_count)
        end

        it "returns error status unprocessable_entity" do
          post events_path, params: inputs_without_multiple_data
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "set flash error message" do
          post events_path, params: inputs_without_multiple_data
          expect(response.body).to include(I18n.t("messages.common.create_fail", data: "Event"))
        end
      end
    end
  end

  describe "PATCH /events" do
    let(:event_params) {
      {
        event: {
          title: "PRINCE",
          description: "testing one two three",
          start_date_part: test_date,
          start_time_part: "07:00",
          end_date_part: test_date,
          end_time_part: "08:00",
          guest_ids: [ "163" ]
        }
      }
    }

    before do
      post events_path, params: event_params
    end

    context "updating with valid attributes," do
      context "when updating title" do
        let(:update_title) {
          {
            event: {
              title: "RAPSTA",
              description: "testing one two three",
              start_date_part: test_date,
              start_time_part: "07:00",
              end_date_part: test_date,
              end_time_part: "08:00",
              guest_ids: [ "163" ]
            }
          }
        }
        it "update the event title in database" do
          event = Event.last
          patch event_path(event), params: update_title
          event.reload
          expect(event.title).to eq("RAPSTA")
        end

        it "update the event title on google calendar" do
          event = Event.last
          patch event_path(event), params: update_title
          event.reload

          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          google_event_id = event.event_guests[0].google_event_id
          google_event = client.get_event("primary", google_event_id)

          expect(google_event.summary).to eq("RAPSTA")
        end

        it "redirect to the event detail page" do
          event = Event.last
          patch event_path(event), params: update_title
          expect(response).to redirect_to(event_path(event))
          expect(response).to have_http_status(:found)
        end
      end

      context "when updating multiple data" do
        let(:update_multiple_data) {
          {
            event: {
              title: "ROCKSTA",
              description: "Rocking one two three",
              start_date_part: test_date,
              start_time_part: "17:00",
              end_date_part: test_date,
              end_time_part: "17:45",
              guest_ids: [ "163" ]
            }
          }
        }
        it "update the event details in database" do
          event = Event.last

          patch event_path(event), params: update_multiple_data
          event.reload
          expect(event.title).to eq("ROCKSTA")
          expect(event.description).to eq("Rocking one two three")
          expect(event.start_time).to eq((test_date + " 17:00 +0630"))
          expect(event.end_time).to eq((test_date + " 17:45 +0630"))
        end

        it "update the event details on google calendar" do
          event = Event.last

          patch event_path(event), params: update_multiple_data
          event.reload
          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          google_event_id = event.event_guests[0].google_event_id
          google_event = client.get_event("primary", google_event_id)

          expect(google_event.summary).to eq("ROCKSTA")
          expect(google_event.description).to eq("Rocking one two three")
          expect(google_event.start.date_time).to eq((test_date + " 17:00 +0630").to_datetime)
          expect(google_event.end.date_time).to eq((test_date + " 17:45 +0630").to_datetime)
        end

        it "redirect to the event detail page" do
          event = Event.last

          patch event_path(event), params: update_multiple_data
          expect(response).to redirect_to(event_path(event))
          expect(response).to have_http_status(:found)
        end
      end
    end

    context "updating with invalid attributes," do
      context "when updating without title," do
        let(:update_with_missing_title) {
          {
            event: {
              title: "",
              description: "Rocking one two three",
              start_date_part: test_date,
              start_time_part: "17:00",
              end_date_part: test_date,
              end_time_part: "17:45",
              guest_ids: [ "163" ]
            }
          }
        }
        it "does not update event data in database" do
          event = Event.last

          patch event_path(event), params: update_with_missing_title
          event.reload
          expect(event.description).not_to eq("Rocking one two three")
        end

        it "does not update event details on google calendar" do
          event = Event.last

          patch event_path(event), params: update_with_missing_title
          event.reload
          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          google_event_id = event.event_guests[0].google_event_id
          google_event = client.get_event("primary", google_event_id)

          expect(google_event.description).not_to eq("Rocking one two three")
        end

        it "return error status and set alert message." do
          event = Event.last
          patch event_path(event), params: update_with_missing_title
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include(I18n.t('messages.common.update_fail', data: "Event"))
        end
      end

      context "when updating with invalid time period," do
        let(:update_with_invalid_time_period) {
          {
            event: {
              title: "ROCKSTA",
              description: "testing one two three",
              start_date_part: test_date,
              start_time_part: "17:00",
              end_date_part: test_date,
              end_time_part: "17:15",
              guest_ids: [ "163" ]
            }
          }
        }
        it "does not update event data in database" do
          event = Event.last

          patch event_path(event), params: update_with_invalid_time_period
          event.reload
          expect(event.title).not_to eq("ROCKSTA")
        end

        it "does not update event details on google calendar" do
          event = Event.last

          patch event_path(event), params: update_with_invalid_time_period
          event.reload
          google_service = GoogleCalendarService.new(user_id)
          client = google_service.google_client

          google_event_id = event.event_guests[0].google_event_id
          google_event = client.get_event("primary", google_event_id)

          expect(google_event.summary).not_to eq("ROCKSTA")
        end

        it "return error status and set alert message." do
          event = Event.last
          patch event_path(event), params: update_with_invalid_time_period
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include(I18n.t('messages.common.update_fail', data: "Event"))
        end
      end
    end
  end

  describe "DELETE /events/:id" do
    let(:event_params) {
      {
        event: {
          title: "TOES",
          description: "came from the bottom",
          start_date_part: test_date,
          start_time_part: "07:00",
          end_date_part: test_date,
          end_time_part: "08:00",
          guest_ids: [ "163" ]
        }
      }
    }
    before do
      post events_path, params: event_params
    end

    context "when event got deleted, " do
      it "delete the event from google calendar" do
        event = Event.last
        google_event_ID = event.event_guests[0].google_event_id

        google_service = GoogleCalendarService.new(user_id)
        client = google_service.google_client
        delete event_path(event)
        google_event = client.get_event("primary", google_event_ID)

        expect(google_event.status).to eq("cancelled")
      end

      it "delete the event from database" do
        event = Event.last
        delete event_path(event)
        expect{ event.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "delete the details from event_guest table" do
        event = Event.last
        delete event_path(event)
        expect(event.event_guests).to be_empty
      end

      it "redirect to event lists" do
        event = Event.last
        delete event_path(event)
        expect(response).to redirect_to(events_path)
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "set notice message" do
        event = Event.last
        delete event_path(event)
        follow_redirect!
        expect(response.body).to include(I18n.t('messages.common.destroy_success', data: "Event"))
      end
    end
  end
end