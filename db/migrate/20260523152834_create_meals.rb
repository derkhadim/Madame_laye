class CreateMeals < ActiveRecord::Migration[8.1]
  def change
    create_table :meals do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day_of_week
      t.integer :meal_type
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.boolean :available, default: true
      t.integer :portion_count, default: 1

      t.timestamps
    end
  end
end
