class CreateTournaments < ActiveRecord::Migration[7.0]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.integer :win_point
      t.integer :draw_point
      t.integer :innings_win_point
      t.integer :follow_on_win_point
      t.integer :round_count

      t.timestamps
    end
  end
end
