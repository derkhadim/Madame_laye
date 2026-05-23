class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.integer :payment_method
      t.decimal :amount, precision: 10, scale: 2
      t.integer :status, default: 0
      t.string :transaction_id
      t.string :phone_number

      t.timestamps
    end
  end
end
