class CreateQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :queries do |t|
      t.string :address
      t.string :activity
      t.integer :radius_search
      t.integer :radius_catchment_area
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
