class CreateMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :matches do |t|
      t.references :tournament, null: false, foreign_key: true
      t.integer :winner_team_id
      t.date :date
      t.boolean :is_won_by_innings, default: false
      t.boolean :is_won_by_follow_on, default: false
      t.boolean :is_draw, default: false

      t.timestamps
    end
  end
end
