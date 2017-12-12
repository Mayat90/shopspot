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

ActiveRecord::Schema.define(version: 20171212162718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: :cascade do |t|
    t.string   "name"
    t.integer  "population"
    t.float    "area"
    t.integer  "insee_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "sexe"
    t.string   "age"
    t.float    "chomage"
    t.float    "revenu"
  end

  create_table "competitors", force: :cascade do |t|
    t.text     "location"
    t.string   "activity"
    t.string   "place_id"
    t.float    "rating"
    t.integer  "number_rating"
    t.text     "opening_hours"
    t.string   "phone_number"
    t.string   "address"
    t.integer  "query_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "name"
    t.index ["query_id"], name: "index_competitors_on_query_id", using: :btree
  end

  create_table "queries", force: :cascade do |t|
    t.string   "address"
    t.string   "activity"
    t.integer  "radius_search"
    t.integer  "radius_catchment_area"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "analytics"
    t.string   "competitors_json"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  add_foreign_key "competitors", "queries"
end
