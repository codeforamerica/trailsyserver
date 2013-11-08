# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ADMIN_USER = (ENV["DEFAULT_ADMIN_USER"] || "admin@example.com").freeze
PASSWORD   = (ENV["DEFAULT_ADMIN_PASSWORD"] || "password").freeze
MPSSC_USER = (ENV["DEFAULT_MPSSC_USER"] || "mpssc@example.com").freeze
NPS_USER   = (ENV["TEST_NPS_USER"] || "nps@example.com").freeze

mpssc = Organization.create({
  code: "MPSSC",
  full_name: "Metro Parks, Serving Summit County",
  phone: "330-867-5511",
  url: "http://www.summitmetroparks.org/"
  })
nps = Organization.create({
  code: "NPS",
  full_name: "Cuyahoga Valley National Park",
  phone: "330.657.2752",
  url: "http://www.nps.gov/cuva/"
  })
cmp = Organization.create({
  code: "CMP",
  full_name: "Cleveland Metroparks",
  phone: "216-635-3286",
  url: "http://clevelandmetroparks.com"
  })

admin = User.find_by(email: ADMIN_USER.dup)
admin.destroy unless admin.nil?
User.create({ 
  email: ADMIN_USER.dup,
  admin: true,
  approved: true,
  password: PASSWORD.dup,
  password_confirmation: PASSWORD.dup
  })
nps_user = User.find_by(email: NPS_USER.dup)
nps_user.destroy unless nps_user.nil?
User.create({ 
  email: NPS_USER.dup,
  admin: false,
  approved: true,
  organization: Organization.find_by(code: "NPS"),
  password: PASSWORD.dup,
  password_confirmation: PASSWORD.dup
  })
mpssc_user = User.find_by(email: MPSSC_USER.dup)
mpssc_user.destroy unless mpssc_user.nil?
User.create({
  email: MPSSC_USER.dup,
  admin: false,
  approved: true,
  organization: Organization.find_by(code: "MPSSC"),
  password: PASSWORD.dup,
  password_confirmation: PASSWORD.dup
  })
