require 'google/api_client/client_secrets.rb'
require 'google/apis/calendar_v3'

class GoogleCalendarService
  def initialize(user_id)
    @user = User.find(user_id)
  end

  def google_client
    client = Google::Apis::CalendarV3::CalendarService.new
    client.authorization = google_secret.to_authorization

    refresh_token(client) if @user.google_token_expired?

    client
  end

  def create_event(event)
    client = google_client
    googleEvent = set_google_event(event)

    client.insert_event('primary', googleEvent)
  end

  def update_event(event)
    client = google_client
    googleEvent = set_google_event(event)

    client.update_event('primary', event.google_calendar_id, googleEvent)
  end

  def delete_event(event_id)
    client = google_client
    client.delete_event('primary', event_id)
  end

  private
    def google_secret
      Google::APIClient::ClientSecrets.new(
        "web" => {
          "access_token" => @user.google_token,
          "refresh_token" => @user.google_refresh_token,
          "client_id" => ENV['GOOGLE_CLIENT_ID'],
          "client_secret" => ENV['GOOGLE_CLIENT_SECRET']
        }
      )
    end

    def set_google_event(event)
      Google::Apis::CalendarV3::Event.new(
        summary: event.title,
        description: event.description,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: event.start_time.iso8601,
          time_zone: "Asia/Yangon"
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: event.end_time.iso8601,
          time_zone: "Asia/Yangon"
        )
      )
    end

    def refresh_token(client)
      begin
        client.authorization.refresh!
        @user.update!(
          google_token: client.authorization.access_token,
          expired_at: Time.current + client.authorization.expires_in.to_i.seconds
        )
      rescue Signet::AuthorizationError => e
        Rails.logger.error "Failed to refresh Google token: #{ e.message }"
        raise e
      end
    end
end