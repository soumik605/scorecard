class CreatePerformances < ActiveRecord::Migration[7.0]
  def change
    create_table :performances do |t|
      t.references :match, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :runs
      t.integer :wickets

      t.timestamps
    end
  end
end
