class CreateDailyProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_products do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :quantity_available
      t.date :date
      t.integer :category

      t.timestamps
    end
  end
end
