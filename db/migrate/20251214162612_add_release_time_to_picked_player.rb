class AddReleaseTimeToPickedPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :picked_players, :release_time, :datetime
    add_column :picked_players, :room_id, :integer
  end
end
