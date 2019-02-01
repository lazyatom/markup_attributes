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

ActiveRecord::Schema.define(version: 2019_01_31_173158) do

  create_table "basic_model_translations", force: :cascade do |t|
    t.integer "basic_model_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["basic_model_id"], name: "index_basic_model_translations_on_basic_model_id"
    t.index ["locale"], name: "index_basic_model_translations_on_locale"
  end

  create_table "basic_models", force: :cascade do |t|
    t.string "type"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
