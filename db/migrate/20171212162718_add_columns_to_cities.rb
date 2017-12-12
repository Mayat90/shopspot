class AddColumnsToCities < ActiveRecord::Migration[5.0]
  def change
    add_column :cities, :sexe, :string
    add_column :cities, :age, :string
    add_column :cities, :chomage, :float
    add_column :cities, :revenu, :float
  end
end
