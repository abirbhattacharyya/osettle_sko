# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110618060123) do

  create_table "feeds", :force => true do |t|
    t.integer  "user_id"
    t.string   "account_number"
    t.string   "client_number"
    t.string   "client_account_number"
    t.float    "balance"
    t.datetime "last_payment_date"
    t.integer  "last_pay_amount"
    t.float    "max_pct"
    t.float    "floor_limit"
    t.integer  "payment_term"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.text     "address1"
    t.text     "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "phone3"
    t.string   "phone4"
    t.string   "client_name1"
    t.string   "client_name2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "offers", :force => true do |t|
    t.integer  "feed_id"
    t.string   "response"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "offer_id"
    t.float    "amount"
    t.string   "payment_type"
    t.date     "payment_date"
    t.string   "name"
    t.string   "cc_no"
    t.integer  "cc_expiry_m"
    t.integer  "cc_expiry_y"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "routing_no"
    t.string   "bank_ac_no"
    t.string   "cc_type"
    t.string   "bank_name"
    t.integer  "security_code"
    t.text     "billing_address"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "web_url"
    t.text     "address1"
    t.text     "address2"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                     :limit => 100
    t.string   "password"
    t.string   "remember_token"
    t.string   "remember_token_expires_at"
    t.boolean  "is_verified",                              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_number"
  end

end
