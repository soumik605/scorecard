class ConvertReleaseTimeToTimestamptz < ActiveRecord::Migration[7.0]
  def up
    # Add new column with timestamptz
    add_column :picked_players, :release_time_tz, :timestamptz
    
    # Convert existing data (assuming stored as IST)
    execute <<-SQL.squish
      UPDATE picked_players 
      SET release_time_tz = release_time AT TIME ZONE 'Asia/Kolkata'
    SQL
    
    # Replace old column
    remove_column :picked_players, :release_time
    rename_column :picked_players, :release_time_tz, :release_time
  end
end
