# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create({ 
 email: ENV["DEFAULT_ADMIN_USER"].dup,
  admin: true,
  approved: true,
  password: ENV["DEFAULT_ADMIN_PASSWORD"],
  password_confirmation: ENV["DEFAULT_ADMIN_PASSWORD"]
})
User.create({ 
  email: ENV["TEST_CVNP_USER"].dup,
  admin: false,
  approved: true,
  organization: "CVNP",
  password: ENV["DEFAULT_ADMIN_PASSWORD"],
  password_confirmation: ENV["DEFAULT_ADMIN_PASSWORD"]
})
User.create({
  email: ENV["TEST_MPSSC_USER"].dup,
  admin: false,
  approved: true,
  organization: "MPSSC",
  password: ENV["DEFAULT_ADMIN_PASSWORD"],
  password_confirmation: ENV["DEFAULT_ADMIN_PASSWORD"]
})

