class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :phone_number
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.text :address
      t.float :latitude
      t.float :longitude
      t.integer :role
      t.decimal :balance, precision: 10, scale: 2, default: 0.0
      t.integer :status, default: 0
      t.string :avatar

      t.timestamps
    end
    add_index :users, :phone_number, unique: true
  end
end
