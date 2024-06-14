class AddGoogleEventIdToEventGuests < ActiveRecord::Migration[7.1]
  def up
    add_column :event_guests, :google_event_id, :string
  end
end
