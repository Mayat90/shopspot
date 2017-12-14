class AddCompetitorsCatchmentToQueries < ActiveRecord::Migration[5.0]
  def change
    add_column :queries, :competitors_catchment, :integer
  end
end
