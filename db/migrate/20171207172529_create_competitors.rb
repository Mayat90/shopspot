class CreateCompetitors < ActiveRecord::Migration[5.0]
  def change
    create_table :competitors do |t|
      t.text :location
      t.string :type
      t.string :place_id
      t.float :rating
      t.integer :number_rating
      t.text :opening_hours
      t.string :phone_number
      t.string :address
      t.references :query, foreign_key: true

      t.timestamps
    end
  end
end
