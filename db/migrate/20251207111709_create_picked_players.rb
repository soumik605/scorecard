class CreatePickedPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :picked_players do |t|
      t.string :team_type
      t.integer :buy_price
      t.integer :player_id
      t.integer :user_id

      t.timestamps
    end
  end
end
