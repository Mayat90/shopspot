class AddResultsCatchmentAreaToQueries < ActiveRecord::Migration[5.0]
  def change
    add_column :queries, :analytics, :string
  end
end
