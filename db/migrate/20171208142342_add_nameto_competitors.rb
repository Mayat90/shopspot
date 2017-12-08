class AddNametoCompetitors < ActiveRecord::Migration[5.0]
  def change
    add_column :competitors, :name, :string
  end
end
