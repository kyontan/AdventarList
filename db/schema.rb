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

ActiveRecord::Schema.define(version: 20161123075226) do

  create_table "articles", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "url"
    t.date     "date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "calendar_id"
    t.integer  "writer_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "in_service_id"
    t.string   "service"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "year",          null: false
  end

  add_index "calendars", ["in_service_id", "service"], name: "index_calendars_on_in_service_id_and_service", unique: true

  create_table "writers", force: :cascade do |t|
    t.string   "name"
    t.string   "in_service_id"
    t.string   "service"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "writers", ["in_service_id", "service"], name: "index_writers_on_in_service_id_and_service", unique: true

end
