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

ActiveRecord::Schema[7.2].define(version: 2023_06_27_165229) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "librum_iam_credentials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type", null: false
    t.boolean "active", default: true, null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["user_id", "type"], name: "index_librum_iam_credentials_on_user_id_and_type"
    t.index ["user_id"], name: "index_librum_iam_credentials_on_user_id"
  end

  create_table "librum_iam_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "slug", default: "", null: false
    t.string "role", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_librum_iam_users_on_email", unique: true
    t.index ["slug"], name: "index_librum_iam_users_on_slug", unique: true
    t.index ["username"], name: "index_librum_iam_users_on_username", unique: true
  end

  add_foreign_key "librum_iam_credentials", "librum_iam_users", column: "user_id"
end
