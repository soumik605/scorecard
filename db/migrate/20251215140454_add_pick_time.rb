class AddPickTime < ActiveRecord::Migration[7.0]
  def change
    add_column :picked_players, :last_pick_datetime, :datetime
    PickedPlayer.update_all('last_pick_datetime = release_time')
  end
end
