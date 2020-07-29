# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_29_133800) do

  create_table "admins", force: :cascade do |t|
    t.string "email", limit: 128, default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "reset_password_token", limit: 128
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 32
    t.string "last_sign_in_ip", limit: 32
    t.string "confirmation_token", limit: 128
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email", limit: 128
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token", limit: 128
    t.datetime "locked_at"
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "google_secret", limit: 128
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "admins_roles", id: false, force: :cascade do |t|
    t.integer "admin_id"
    t.integer "role_id"
    t.index ["admin_id", "role_id"], name: "index_admins_roles_on_admin_id_and_role_id"
    t.index ["admin_id"], name: "index_admins_roles_on_admin_id"
    t.index ["role_id"], name: "index_admins_roles_on_role_id"
  end

  create_table "appeal_stuffs", force: :cascade do |t|
    t.integer "appeal_id"
    t.string "file"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["appeal_id"], name: "index_appeal_stuffs_on_appeal_id"
  end

  create_table "appeals", force: :cascade do |t|
    t.integer "contract_id"
    t.datetime "at"
    t.string "cause"
    t.string "amount"
    t.string "tx_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "images"
    t.integer "user_id"
    t.index ["contract_id"], name: "index_appeals_on_contract_id"
  end

  create_table "arbitrament_results", force: :cascade do |t|
    t.integer "contract_id"
    t.integer "owner_rate"
    t.integer "renter_rate"
    t.string "tx_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contract_id"], name: "index_arbitrament_results_on_contract_id"
  end

  create_table "bills", force: :cascade do |t|
    t.integer "contract_id"
    t.datetime "pay_at"
    t.string "item"
    t.decimal "amount", precision: 20, scale: 8
    t.string "tx_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "paied"
    t.boolean "paid"
    t.boolean "in_or_out", default: true
    t.index ["contract_id"], name: "index_bills_on_contract_id"
  end

  create_table "captchas", force: :cascade do |t|
    t.string "phone", limit: 16
    t.string "captcha", limit: 8
    t.datetime "expire_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "renter_id"
    t.integer "owner_id"
    t.integer "promoter_id"
    t.string "state"
    t.string "room_address"
    t.string "room_district"
    t.decimal "room_area"
    t.string "room_no"
    t.string "room_certificate_owner"
    t.string "room_usage"
    t.integer "room_capacity_min"
    t.integer "room_capacity_max"
    t.boolean "room_is_pledged"
    t.string "room_certificate"
    t.string "trans_no"
    t.string "trans_currency"
    t.decimal "trans_monthly_price"
    t.decimal "trans_pledge_amount"
    t.string "trans_amount_pledge"
    t.string "trans_coupon_code"
    t.string "trans_coupon_rate"
    t.decimal "trans_agency_fee_rate_origin"
    t.decimal "trans_agency_fee_rate"
    t.string "trans_agency_fee_by"
    t.integer "trans_period"
    t.date "trans_begin_on"
    t.date "trans_end_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "chain_address"
    t.boolean "is_on_chain", default: false
    t.integer "currency_id"
    t.decimal "trans_pay_amount"
    t.index ["owner_id"], name: "index_contracts_on_owner_id"
    t.index ["promoter_id"], name: "index_contracts_on_promoter_id"
    t.index ["renter_id"], name: "index_contracts_on_renter_id"
  end

  create_table "contracts_users", force: :cascade do |t|
    t.integer "contract_id"
    t.integer "user_id"
    t.integer "renter_rate"
    t.integer "owner_rate"
    t.string "images"
    t.datetime "at"
    t.string "desc"
    t.boolean "done", default: false
    t.index ["contract_id"], name: "index_contracts_users_on_contract_id"
    t.index ["user_id"], name: "index_contracts_users_on_user_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code"
    t.integer "contract_id"
    t.integer "user_id"
    t.decimal "coupon_rate"
    t.boolean "is_used"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contract_id"], name: "index_coupons_on_contract_id"
    t.index ["user_id"], name: "index_coupons_on_user_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name", limit: 32, default: "", null: false
    t.string "addr", limit: 512, default: "", null: false
    t.integer "decimals", default: 18, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "images", force: :cascade do |t|
    t.integer "user_id"
    t.string "file"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "kycs", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 32
    t.string "id_no", limit: 32
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "front_img_id"
    t.integer "back_img_id"
    t.index ["user_id"], name: "index_kycs_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.integer "contract_id"
    t.integer "user_id"
    t.datetime "at"
    t.string "reply"
    t.string "images"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contract_id"], name: "index_replies_on_contract_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 32
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "no", default: 0, null: false
    t.string "price_addr", limit: 512, default: "", null: false
    t.string "join_coin_addr", limit: 512, default: "", null: false
    t.integer "time_level", default: 0, null: false
    t.bigint "invent_level", default: 0, null: false
    t.integer "player_number", default: 0, null: false
    t.integer "winer_number", default: 0, null: false
    t.boolean "is_deleted", default: false, null: false
    t.integer "rate", default: 0, null: false
    t.integer "cur_round", default: 0, null: false
    t.datetime "begin_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "next_round_at"
    t.integer "interval_minute"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "contract_id"
    t.datetime "at"
    t.string "content"
    t.string "tx_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contract_id"], name: "index_transactions_on_contract_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "phone", limit: 16
    t.string "type", limit: 16
    t.string "status", limit: 16
    t.string "nick_name", limit: 32
    t.string "password_md5", limit: 32
    t.string "eth_wallet_address", limit: 64
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "desc"
  end

end
