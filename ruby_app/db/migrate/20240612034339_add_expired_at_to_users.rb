class AddExpiredAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :expired_at, :datetime
  end
end
