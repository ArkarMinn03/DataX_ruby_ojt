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

  def list_events(calendar_id = 'primary')
    client = google_client
    response = client.list_events(
      calendar_id,
      max_results: 10,
      single_events: true,
      order_by: 'startTime',
      time_min: Time.now.iso8601
    )
    eventsList = []
    if response.items.empty?
      Rails.logger.info 'No upcoming events found.'
      return eventsList
    else
      response.items.each do |event|
        start = event.start.date || event.start.date_time
        eventsList << { summary: event.summary, start: start, id: event.id }
      end
      return eventsList
    end
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