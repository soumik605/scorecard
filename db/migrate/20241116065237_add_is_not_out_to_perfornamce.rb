class AddIsNotOutToPerfornamce < ActiveRecord::Migration[7.0]
  def change
    add_column :performances, :is_not_out, :boolean, defaut: false
  end
end
