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

ActiveRecord::Schema.define(version: 20151228143528) do

  create_table "comments", force: :cascade do |t|
    t.string   "body"
    t.integer  "user_id"
    t.integer  "port_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["port_id"], name: "index_comments_on_port_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "customers", force: :cascade do |t|
    t.string   "account"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "name"
    t.string   "ip"
    t.integer  "location_id"
    t.string   "type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "model"
    t.boolean  "fttb",        default: false
  end

  add_index "nodes", ["fttb"], name: "index_nodes_on_fttb"
  add_index "nodes", ["location_id"], name: "index_nodes_on_location_id"
  add_index "nodes", ["model"], name: "index_nodes_on_model"

  create_table "ports", force: :cascade do |t|
    t.string   "name"
    t.string   "state"
    t.string   "description"
    t.integer  "node_id"
    t.integer  "customer_id"
    t.boolean  "reserved",    default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "ports", ["customer_id"], name: "index_ports_on_customer_id"
  add_index "ports", ["node_id"], name: "index_ports_on_node_id"

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "auth_token",             default: ""
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
