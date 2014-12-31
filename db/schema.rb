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

ActiveRecord::Schema.define(version: 20141231102638) do

  create_table "arrivals", force: true do |t|
    t.integer  "user_id",      null: false
    t.integer  "building_id",  null: false
    t.integer  "check_type"
    t.datetime "date",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "begin_or_end"
  end

  create_table "bosses", force: true do |t|
    t.string "name"
    t.string "phone"
  end

  create_table "buildings", force: true do |t|
    t.string   "name"
    t.string   "main_address"
    t.string   "arrival_address"
    t.string   "status"
    t.string   "linkQR"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "main_address_id"
    t.string   "contact_phone"
    t.string   "contact_name"
  end

  create_table "buildingscontracts", id: false, force: true do |t|
    t.integer "contract_id", null: false
    t.integer "building_id", null: false
  end

  create_table "contracts", force: true do |t|
    t.integer  "contract_id"
    t.string   "company"
    t.datetime "date_of_signing"
    t.integer  "user_id"
    t.string   "comment"
    t.string   "description"
    t.string   "name_contract"
    t.string   "period"
    t.datetime "end_time"
    t.datetime "begin_time"
  end

  create_table "main_address", force: true do |t|
    t.string "name"
  end

  create_table "pairs", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "requistion_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "check_in"
    t.datetime "check_out"
  end

  create_table "requistions", force: true do |t|
    t.string   "object",                                       null: false
    t.integer  "status",               limit: 255, default: 0
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "main_address"
    t.string   "arrival_address"
    t.string   "contact_name",                                 null: false
    t.string   "contact_phone",                                null: false
    t.string   "type_requistion",                              null: false
    t.string   "info"
    t.integer  "building_id"
    t.string   "subtype_requistions"
    t.string   "requistion_comment"
    t.integer  "category"
    t.integer  "contract_id"
    t.integer  "raiting",                          default: 0
    t.datetime "time_assgned"
    t.datetime "time_adopted_in_work"
    t.datetime "time_running"
    t.datetime "time_done"
    t.datetime "time_completed"
    t.datetime "time_deadline"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.integer  "boss_id",                default: 0
    t.string   "remember_token"
    t.integer  "status",                 default: 0
    t.string   "phone"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
