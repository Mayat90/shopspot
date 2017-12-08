class FixColumnType < ActiveRecord::Migration[5.0]
  def change
    rename_column :competitors, :type, :activity
  end
end
