# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_17_083800) do

  create_table "chatimages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "chat_id"
    t.string "image", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chat_id"], name: "index_chatimages_on_chat_id"
  end

  create_table "chats", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_customer_id"
    t.text "body"
    t.string "chat_image"
    t.string "send_flg", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_customer_id"], name: "index_chats_on_line_customer_id"
  end

  create_table "images", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "message_id"
    t.string "image", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id"], name: "index_images_on_message_id"
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "l_groups", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_l_groups_on_user_id"
  end

  create_table "line_customer_l_groups", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "l_group_id"
    t.bigint "line_customer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["l_group_id"], name: "index_line_customer_l_groups_on_l_group_id"
    t.index ["line_customer_id"], name: "index_line_customer_l_groups_on_line_customer_id"
  end

  create_table "line_customer_memos", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_customer_id"
    t.string "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_customer_id"], name: "index_line_customer_memos_on_line_customer_id"
  end

  create_table "line_customers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "original_id", null: false
    t.string "name", null: false
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "blockflg"
    t.index ["user_id"], name: "index_line_customers_on_user_id"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", null: false
    t.text "body", null: false
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "push_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "push_line_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_push_users_on_user_id"
  end

  create_table "tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.string "chanel_id", limit: 10, null: false
    t.string "chanel_secret", limit: 32, null: false
    t.string "messaging_token", limit: 172, null: false
    t.string "login_token", limit: 172, null: false
    t.string "access_id", limit: 12, null: false
    t.string "web_hook_url"
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "chatimages", "chats"
  add_foreign_key "chats", "line_customers"
  add_foreign_key "images", "messages"
  add_foreign_key "images", "users"
  add_foreign_key "l_groups", "users"
  add_foreign_key "line_customer_l_groups", "l_groups"
  add_foreign_key "line_customer_l_groups", "line_customers"
  add_foreign_key "line_customer_memos", "line_customers"
  add_foreign_key "line_customers", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "push_users", "users"
  add_foreign_key "tokens", "users"
end
