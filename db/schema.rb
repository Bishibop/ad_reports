# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160717232138) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adwords_reports", force: :cascade do |t|
    t.integer  "cost"
    t.integer  "impressions"
    t.float    "click_through_rate"
    t.integer  "clicks"
    t.integer  "all_conversions"
    t.float    "all_conversion_rate"
    t.integer  "cost_per_all_conversion"
    t.integer  "conversions"
    t.float    "conversion_rate"
    t.integer  "cost_per_conversion"
    t.integer  "average_cost_per_click"
    t.float    "average_position"
    t.integer  "client_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.date     "date",                    null: false
  end

  add_index "adwords_reports", ["client_id"], name: "index_adwords_reports_on_client_id", using: :btree

  create_table "bingads_reports", force: :cascade do |t|
    t.float    "cost"
    t.integer  "impressions"
    t.float    "click_through_rate"
    t.integer  "clicks"
    t.integer  "conversions"
    t.float    "cost_per_conversion"
    t.float    "average_cost_per_click"
    t.float    "average_position"
    t.float    "conversion_rate"
    t.integer  "client_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.date     "date",                   null: false
  end

  add_index "bingads_reports", ["client_id"], name: "index_bingads_reports_on_client_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name",               null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "customer_id"
    t.string   "login_domain",       null: false
    t.string   "adwords_cid"
    t.string   "bing_ads_aid"
    t.string   "marchex_account_id"
  end

  add_index "clients", ["customer_id"], name: "index_clients_on_customer_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "name",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "bing_ads_access_token"
    t.string   "bing_ads_refresh_token"
    t.string   "adwords_access_token"
    t.string   "adwords_refresh_token"
    t.datetime "adwords_issued_at"
    t.integer  "adwords_expires_in_seconds"
    t.datetime "bing_ads_issued_at"
    t.integer  "bing_ads_expires_in_seconds"
    t.string   "login_domain",                null: false
  end

  create_table "marchex_call_records", force: :cascade do |t|
    t.string   "playback_url"
    t.string   "dna_classification"
    t.string   "status"
    t.integer  "duration"
    t.string   "phone_number"
    t.string   "campaign"
    t.string   "caller_name"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "client_id"
    t.string   "marchex_call_id",    null: false
    t.string   "group_name"
    t.string   "pretty_duration"
    t.datetime "start_time"
  end

  add_index "marchex_call_records", ["client_id"], name: "index_marchex_call_records_on_client_id", using: :btree
  add_index "marchex_call_records", ["marchex_call_id", "client_id"], name: "index_marchex_call_records_on_marchex_call_id_and_client_id", unique: true, using: :btree

  add_foreign_key "adwords_reports", "clients"
  add_foreign_key "bingads_reports", "clients"
  add_foreign_key "clients", "customers"
  add_foreign_key "marchex_call_records", "clients"
end
