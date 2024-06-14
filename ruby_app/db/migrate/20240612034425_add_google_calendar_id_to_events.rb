class AddGoogleCalendarIdToEvents < ActiveRecord::Migration[7.1]
  def up
    add_column :events, :google_calendar_id, :string
  end

  def down
    remove_column :events, :google_canlendar_id
  end
end
