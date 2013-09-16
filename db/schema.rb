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

ActiveRecord::Schema.define(version: 20130915212439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "trailheads", force: true do |t|
    t.string   "name"
    t.string   "steward"
    t.string   "source"
    t.string   "trail1"
    t.string   "trail2"
    t.string   "trail3"
    t.string   "trail4"
    t.string   "trail5"
    t.string   "trail6"
    t.string   "parking"
    t.string   "water"
    t.string   "restrooms"
    t.string   "kiosk"
    t.string   "park"
    t.spatial  "geom",       limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trails", force: true do |t|
    t.string   "name"
    t.string   "opdmd_access"
    t.string   "source"
    t.string   "steward"
    t.decimal  "length"
    t.string   "opdmd"
    t.string   "equestrian"
    t.string   "xcntryski"
    t.string   "trlsurface"
    t.string   "dogs"
    t.string   "hike"
    t.string   "roadbike"
    t.text     "description"
    t.string   "difficulty"
    t.string   "hike_time"
    t.string   "map_url"
    t.string   "surface"
    t.string   "designatio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trailsegments", force: true do |t|
    t.string   "steward"
    t.decimal  "length"
    t.string   "source"
    t.spatial  "geom",       limit: {:srid=>4326, :type=>"multi_line_string", :geographic=>true}
    t.string   "trail1"
    t.string   "trail2"
    t.string   "trail3"
    t.string   "trail4"
    t.string   "trail5"
    t.string   "trail6"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
