# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

mpssc = Organization.create({
  code: "MPSSC",
  full_name: "Metro Parks, Serving Summit County",
  phone: "330-867-5511",
  url: "http://www.summitmetroparks.org/"
  })
nps = Organization.create({
  code: "NPS",
  full_name: "Cuyahoga Valley National Park",
  phone: "216-524-1497",
  url: "http://www.nps.gov/cuva/"
  })
cmp = Organization.create({
  code: "CMP",
  full_name: "Cleveland Metroparks",
  phone: "216-635-3286",
  url: "http://clevelandmetroparks.com"
  })

admin = User.find_by(email: ENV["DEFAULT_ADMIN_USER"])
admin.destroy unless admin_user.nil?
User.create({ 
  email: ENV["DEFAULT_ADMIN_USER"].dup,
  admin: true,
  approved: true,
  password: ENV["DEFAULT_ADMIN_PASSWORD"],
  password_confirmation: ENV["DEFAULT_ADMIN_PASSWORD"]
  })
nps_user = User.find_by(email: ENV["TEST_NPS_USER"])
nps_user.destroy unless nps_user.nil?
User.create({ 
  email: ENV["TEST_NPS_USER"].dup,
  admin: false,
  approved: true,
  organization: Organization.find_by(code: "NPS"),
  password: ENV["DEFAULT_ADMIN_PASSWORD"],
  password_confirmation: ENV["DEFAULT_ADMIN_PASSWORD"]
  })
mpssc_user = User.find_by(email: ENV["TEST_MPSSC_USER"])
mpssc_user.destroy unless mpssc_user.nil?
User.create({
  email: ENV["TEST_MPSSC_USER"].dup,
  admin: false,
  approved: true,
  organization: Organization.find_by(code: "MPSSC"),
  password: ENV["DEFAULT_ADMIN_PASSWORD"],
  password_confirmation: ENV["DEFAULT_ADMIN_PASSWORD"]
  })

