class AddPertinenceGradeToQueries < ActiveRecord::Migration[5.0]
  def change
    add_column :queries, :pertinence_grade, :integer
  end
end
