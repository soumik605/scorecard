class AddWinnerUpdatedAtToMatch < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :winner_updated_at, :datetime

    Match.all.each do |match|
      match.update(winner_updated_at: match.updated_at)
    end
  end
end
