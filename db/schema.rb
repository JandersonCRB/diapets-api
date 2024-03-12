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

ActiveRecord::Schema[7.1].define(version: 2024_03_12_005943) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "insulin_applications", force: :cascade do |t|
    t.integer "glucose_level"
    t.integer "insulin_units"
    t.bigint "user_id"
    t.datetime "application_time"
    t.string "observations"
    t.bigint "pet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_insulin_applications_on_pet_id"
    t.index ["user_id"], name: "index_insulin_applications_on_user_id"
  end

  create_table "pet_owners", id: false, force: :cascade do |t|
    t.bigint "pet_id"
    t.bigint "owner_id"
    t.string "ownership_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_pet_owners_on_owner_id"
    t.index ["pet_id", "owner_id"], name: "index_pet_owners_on_pet_id_and_owner_id", unique: true
    t.index ["pet_id"], name: "index_pet_owners_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.string "name"
    t.string "species"
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 100
    t.string "last_name", limit: 300
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "insulin_applications", "pets"
  add_foreign_key "insulin_applications", "users"
  add_foreign_key "pet_owners", "pets"
  add_foreign_key "pet_owners", "users", column: "owner_id"
end
