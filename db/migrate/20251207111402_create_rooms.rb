class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.references :user, null: false, foreign_key: true
      t.string :code

      t.timestamps
    end
  end
end
