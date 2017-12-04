class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :population
      t.float :area
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
