# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'



CSV.foreach('lib/seeds/cities.csv', encoding: 'iso-8859-1:utf-8') do |row|
  City.create!(
  name: row[0],
  insee_id: row[1],
  area: row[2],
  longitude: row[3],
  latitude: row[4],
  population: row[5]
   )
end

p "ok"