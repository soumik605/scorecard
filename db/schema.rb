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

ActiveRecord::Schema[7.0].define(version: 2024_11_12_171008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matches", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.integer "winner_team_id"
    t.date "date"
    t.boolean "is_won_by_innings", default: false
    t.boolean "is_won_by_follow_on", default: false
    t.boolean "is_draw", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
  end

  create_table "performances", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "player_id", null: false
    t.integer "runs"
    t.integer "wickets"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_performances_on_match_id"
    t.index ["player_id"], name: "index_performances_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.integer "captain_id"
    t.integer "win_point"
    t.integer "innings_win_point"
    t.integer "follow_on_win_point"
    t.integer "total_point"
    t.bigint "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_teams_on_match_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.integer "win_point"
    t.integer "draw_point"
    t.integer "innings_win_point"
    t.integer "follow_on_win_point"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "matches", "tournaments"
  add_foreign_key "performances", "matches"
  add_foreign_key "performances", "players"
  add_foreign_key "teams", "matches"
end
