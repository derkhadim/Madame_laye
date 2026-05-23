class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :cook, null: false, foreign_key: { to_table: :users }
      t.references :delivery_driver, null: true, foreign_key: { to_table: :users }
      t.integer :status, default: 0
      t.text :delivery_address
      t.float :delivery_latitude
      t.float :delivery_longitude
      t.decimal :total_amount, precision: 10, scale: 2
      t.text :notes
      t.boolean :client_received, default: false

      t.timestamps
    end
  end
end
