class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    drop_table :users, if_exists: true
    
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.integer :room_id, null: true, optional: true

      t.timestamps
    end
  end
end
