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

ActiveRecord::Schema.define(version: 20131101182924) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "organizations", force: true do |t|
    t.string   "code"
    t.string   "full_name"
    t.string   "phone"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "photorecords", force: true do |t|
    t.integer  "source_id"
    t.string   "name"
    t.integer  "trail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "credit"
  end

  create_table "trailheads", force: true do |t|
    t.string   "name"
    t.integer  "steward_id"
    t.integer  "source_id"
    t.string   "trail1"
    t.string   "trail2"
    t.string   "trail3"
    t.string   "trail4"
    t.string   "trail5"
    t.string   "trail6"
    t.string   "parking"
    t.string   "drinkwater"
    t.string   "restrooms"
    t.string   "kiosk"
    t.string   "contactnum"
    t.spatial  "geom",       limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "park"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
  end

  create_table "trails", force: true do |t|
    t.string   "name"
    t.integer  "source_id"
    t.integer  "steward_id"
    t.decimal  "length"
    t.string   "accessible"
    t.string   "roadbike"
    t.string   "hike"
    t.string   "mtnbike"
    t.string   "equestrian"
    t.string   "xcntryski"
    t.string   "conditions"
    t.string   "trlsurface"
    t.string   "map_url"
    t.string   "dogs"
    t.text     "description"
    t.integer  "status",      default: 0
    t.string   "statustext"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trailsegments", force: true do |t|
    t.integer  "source_id"
    t.integer  "steward_id"
    t.decimal  "length"
    t.spatial  "geom",       limit: {:srid=>4326, :type=>"multi_line_string", :geographic=>true}
    t.string   "trail1"
    t.string   "trail2"
    t.string   "trail3"
    t.string   "trail4"
    t.string   "trail5"
    t.string   "trail6"
    t.string   "accessible"
    t.string   "roadbike"
    t.string   "hike"
    t.string   "mtnbike"
    t.string   "equestrian"
    t.string   "xcntryski"
    t.string   "conditions"
    t.string   "trlsurface"
    t.string   "dogs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.boolean  "approved",               default: false, null: false
    t.integer  "organization_id"
  end

  add_index "users", ["approved"], :name => "index_users_on_approved"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
