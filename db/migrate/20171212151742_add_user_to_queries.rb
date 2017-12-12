class AddUserToQueries < ActiveRecord::Migration[5.0]
  def change
    add_reference :queries, :user, foreign_key: true
  end
end
