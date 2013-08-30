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

ActiveRecord::Schema.define(version: 20130829213732) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "trailheads", force: true do |t|
    t.string   "name"
    t.string   "source"
    t.string   "trail1"
    t.string   "trail2"
    t.string   "trail3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "geom",       limit: {:srid=>4326, :type=>"point"}
  end

  create_table "trails", force: true do |t|
    t.string   "name"
    t.string   "opdmd_access"
    t.string   "source"
    t.string   "steward"
    t.decimal  "length"
    t.string   "horses"
    t.string   "dogs"
    t.string   "bikes"
    t.text     "description"
    t.string   "difficulty"
    t.string   "hike_time"
    t.string   "print_map_url"
    t.string   "surface"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trailsegments", force: true do |t|
    t.decimal  "length"
    t.string   "source"
    t.string   "steward"
    t.string   "name1"
    t.string   "name2"
    t.string   "name3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "geom",       limit: {:srid=>4326, :type=>"multi_line_string"}
  end

end
