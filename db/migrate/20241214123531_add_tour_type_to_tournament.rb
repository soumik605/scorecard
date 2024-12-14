class AddTourTypeToTournament < ActiveRecord::Migration[7.0]
  def change
    add_column :tournaments, :tour_type, :integer

    Tournament.update_all(tour_type: 1)
  end
end
