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

ActiveRecord::Schema.define(version: 20191024214458) do

  create_table "moving_averages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date", null: false
    t.float "price", limit: 24, null: false
    t.float "ma75", limit: 24, null: false
    t.float "ma25", limit: 24
    t.boolean "golden_cross"
    t.datetime "golden_date"
    t.boolean "dead_cross"
    t.datetime "dead_date"
  end

  create_table "xrps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date", null: false
    t.float "price", limit: 24, null: false
    t.float "open", limit: 24, null: false
    t.float "high", limit: 24, null: false
    t.float "low", limit: 24, null: false
    t.float "change", limit: 24
  end

end
