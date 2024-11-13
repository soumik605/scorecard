class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :captain_id
      t.integer :win_point
      t.integer :innings_win_point
      t.integer :follow_on_win_point
      t.integer :total_point
      t.references :match, foreign_key: true

      t.timestamps
    end
  end
end
