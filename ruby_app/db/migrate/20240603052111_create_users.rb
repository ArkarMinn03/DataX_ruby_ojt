class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :encrypted_password
      t.text :about_me
      t.text :profile

      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
