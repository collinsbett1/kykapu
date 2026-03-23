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

ActiveRecord::Schema[8.1].define(version: 2026_02_19_093000) do
  create_table "group_deals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "initiator_id", null: false
    t.integer "locked_price_cents", null: false
    t.integer "product_id", null: false
    t.string "status", default: "forming", null: false
    t.integer "target_size", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_group_deals_on_expires_at"
    t.index ["initiator_id"], name: "index_group_deals_on_initiator_id"
    t.index ["product_id"], name: "index_group_deals_on_product_id"
    t.index ["status"], name: "index_group_deals_on_status"
  end

  create_table "group_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_deal_id", null: false
    t.datetime "joined_at", null: false
    t.string "status", default: "committed", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_deal_id", "user_id"], name: "index_group_participants_on_group_deal_id_and_user_id", unique: true
    t.index ["group_deal_id"], name: "index_group_participants_on_group_deal_id"
    t.index ["status"], name: "index_group_participants_on_status"
    t.index ["user_id"], name: "index_group_participants_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_deal_id", null: false
    t.string "status", default: "pending", null: false
    t.integer "total_cents", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_deal_id"], name: "index_orders_on_group_deal_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.datetime "authorized_at"
    t.datetime "captured_at"
    t.datetime "created_at", null: false
    t.string "intent_id", null: false
    t.integer "order_id", null: false
    t.string "provider", null: false
    t.datetime "refunded_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["provider", "intent_id"], name: "index_payments_on_provider_and_intent_id", unique: true
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "group_price_cents", null: false
    t.integer "group_window_minutes", default: 60, null: false
    t.integer "inventory_count", default: 0, null: false
    t.integer "min_group_size", default: 2, null: false
    t.integer "solo_price_cents", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "group_deals", "products"
  add_foreign_key "group_deals", "users", column: "initiator_id"
  add_foreign_key "group_participants", "group_deals"
  add_foreign_key "group_participants", "users"
  add_foreign_key "orders", "group_deals"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
end
