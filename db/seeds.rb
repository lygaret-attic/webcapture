# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u = User.create!(email: "jon@accidental.cc", password: "bubble")
10.times do
  Capture.create!(user: u, content: Forgery::LoremIpsum.paragraph)
end
