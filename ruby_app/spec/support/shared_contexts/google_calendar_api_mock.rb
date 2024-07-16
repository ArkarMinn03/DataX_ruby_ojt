RSpec.shared_context "Google calendar Api Mock" do
  before do
    stub_request(:get, /https:\/\/www.googleapis.com\/calendar\/v3\/calendars\/.+\/events/).to_return(
      status: 200,
      body: {
        "kind": "calendar#events",
        "etag": "\"etag\"",
        "summary": "Test Calendar",
        "items": [
          {
            "kind": "calendar#event",
            "etag": "\"etag1\"",
            "id": "event1",
            "status": "confirmed",
            "htmlLink": "https://www.google.com/calendar/event?eid=event1",
            "summary": "Test Event 1",
            "description": "This is a test event.",
            "start": { "dateTime": "2024-07-12T10:00:00+06:30" },
            "end": { "dateTime": "2024-07-12T12:00:00+06:30" },
          },
          {
            "kind": "calendar#event",
            "etag": "\"etag2\"",
            "id": "event2",
            "status": "confirmed",
            "htmlLink": "https://www.google.com/calendar/event?eid=event2",
            "summary": "Test Event 2",
            "description": "This is second test event.",
            "start": { "dateTime": "2024-07-12T10:00:00+06:30" },
            "end": { "dateTime": "2024-07-12T12:00:00+06:30" },
          }
        ]
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end