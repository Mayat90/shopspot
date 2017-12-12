class AddCompetitorsToQueries < ActiveRecord::Migration[5.0]
  def change
    add_column :queries, :competitors_json, :string
  end
end
