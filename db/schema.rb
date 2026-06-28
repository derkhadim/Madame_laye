# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_23_181801) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "cube"
  enable_extension "earthdistance"
  enable_extension "pg_catalog.plpgsql"

  create_table "daily_products", force: :cascade do |t|
    t.integer "category"
    t.datetime "created_at", null: false
    t.date "date"
    t.text "description"
    t.string "name"
    t.decimal "price"
    t.integer "quantity_available"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_daily_products_on_user_id"
  end

  create_table "meals", force: :cascade do |t|
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.text "description"
    t.integer "meal_type"
    t.string "name"
    t.integer "portion_count", default: 1
    t.decimal "price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_meals_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.bigint "order_id", null: false
    t.integer "quantity"
    t.decimal "unit_price"
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_order_items_on_item"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.boolean "client_received", default: false
    t.bigint "cook_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "delivery_address"
    t.bigint "delivery_driver_id"
    t.float "delivery_latitude"
    t.float "delivery_longitude"
    t.text "notes"
    t.integer "status", default: 0
    t.decimal "total_amount", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["cook_id"], name: "index_orders_on_cook_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["delivery_driver_id"], name: "index_orders_on_delivery_driver_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.bigint "order_id", null: false
    t.integer "payment_method"
    t.string "phone_number"
    t.integer "status", default: 0
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_payments_on_customer_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "quartiers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nom", null: false
    t.datetime "updated_at", null: false
    t.index ["nom"], name: "index_quartiers_on_nom", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "meal_id", null: false
    t.bigint "order_id", null: false
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["meal_id"], name: "index_reviews_on_meal_id"
    t.index ["order_id"], name: "index_reviews_on_order_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "address"
    t.string "avatar"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.float "latitude"
    t.float "longitude"
    t.string "password_digest"
    t.string "phone_number"
    t.integer "role"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "withdrawals", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "processed_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_withdrawals_on_user_id"
  end

  add_foreign_key "daily_products", "users"
  add_foreign_key "meals", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users", column: "cook_id"
  add_foreign_key "orders", "users", column: "customer_id"
  add_foreign_key "orders", "users", column: "delivery_driver_id"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "users", column: "customer_id"
  add_foreign_key "reviews", "meals"
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "users"
  add_foreign_key "withdrawals", "users"
end
