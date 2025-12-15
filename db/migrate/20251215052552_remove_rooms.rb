class RemoveRooms < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        execute("DELETE FROM picked_players")
        execute("DELETE FROM rooms")
      end
      dir.down do
        raise ActiveRecord::IrreversibleMigration
      end
    end
  end
end
