class AddIsRemovedToTournament < ActiveRecord::Migration[7.0]
  def change
    add_column :tournaments, :is_removed, :boolean, default: false
  end
end
