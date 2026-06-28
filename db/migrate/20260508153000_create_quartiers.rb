class CreateQuartiers < ActiveRecord::Migration[8.0]
  def change
    create_table :quartiers do |t|
      t.string :nom, null: false

      t.timestamps
    end

    add_index :quartiers, :nom, unique: true
  end
end
