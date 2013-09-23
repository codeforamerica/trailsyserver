# TrailsyServer

This will eventually provide:

 - a REST-style interface to trail data for consumption by [Trailsy](http://www.github.com/danavery/trailsy) (and possibly others). 
 - an interface for trail stewards to upload and maintain their trail data in the Trailsy database, as well as provide status updates, closure updates, photos, and institutional information for invidivual trails.

This is still very much in early development. We hope to merge this repo and the [Trailsy](http://www.github.com/danavery/trailsy) repo soon.

### Sample working resource requests
 - [http://trailsyserver-prod.herokuapp.com/trails.json](http://trailsyserver-prod.herokuapp.com/trails.json)
 - [http://trailsyserver-prod.herokuapp.com/trailheads.json?loc=41.1,-81.5](http://trailsyserver-prod.herokuapp.com/trailheads.json?loc=41.1,-81.5)
 - [http://trailsyserver-prod.herokuapp.com/trailsegments.json](http://trailsyserver-prod.herokuapp.com/trailsegments.json)

## Setup notes

### Heroku setup

(more instructions to come on DB setup)

To set up an instance on Heroku, you need a instance of PostGIS available (we're currently using one installed an EC2 server)

To install on Heroku, you'll need to set the following app config vars:

 - BUILDPACK_URL:              https://github.com/ddollar/heroku-buildpack-multi.git
 - GDAL_BINDIR:                /app/vendor/gdal/1.10.0/bin
 - DATABASE_URL:               postgis://[db_username]:[db_password]@[host]:[port]/[db_name]

To add these to your Heroku app, assuming you have the Heroku toolbelt installed:

    heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
    heroku config:add GDAL_BINDIR=/app/vendor/gdal/1.10.0/bin
    heroku config:add DATABASE_URL=[your database URL]

---

### Local setup

You need the GDAL/OGR package installed locally.

Environment variables required:

#### For production DB
 - TRAILSY_DB_USER=[name of database user]
 - TRAILSY_DB_HOST=[database host]
 - TRAILSY_DB_PASSWORD=[database password]
 - TRAILSY_SU_PASSWORD=[database password]
 - TRAILSY_DB_DATABASE=[production database name]

#### For development DB
 - TRAILSY_DB_DEV_USER=[name of database user]
 - TRAILSY_DB_DEV_HOST=[database host]
 - TRAILSY_DB_DEV_PASSWD=[database password]
 - TRAILSY_DB_DEV_SU_PASSWD=[database password]
 - TRAILSY_DB_DEV_DATABASE=[development database name]

#### Path to GDAL binaries (for ogr2ogr)
 - GDAL_BINDIR=[path]  # depends on install -- if using OS X Homebrew, it's `/usr/local/bin`

---

#### Users created on initialization
Three users will be set up on DB creation. They should be email addresses:

 - DEFAULT_ADMIN_USER

These users will acquire more generic names soon:

 - TEST_CVNP_USER
 - TEST_MPSSC_USER

All of these initial users will share the password in the environment variable

 - DEFAULT_ADMIN_PASSWORD
