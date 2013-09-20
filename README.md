# TrailsyServer

This will eventually provide:

 - a REST-style interface to trail data for consumption by [Trailsy](http://www.github.com/danavery/trailsy) (and possibly others). 
 - an interface for trail stewards to upload and maintain their trail data in the Trailsy database, as well as provide status updates, closure updates, photos, and institutional information for invidivual trails.
 - data structure and API informed by [trail standards draft](https://docs.google.com/document/d/1frt5HkKTdqEaNEnfk2Dq9IYxctvPjVnoU_F33Px2zSQ).
 

This is still very much in early development. We hope to merge this repo and the [Trailsy](http://www.github.com/danavery/trailsy) repo soon.

### Sample working resource requests
 - [http://trailsyserver-prod.herokuapp.com/trails.json](http://trailsyserver-prod.herokuapp.com/trails.json)
 - [http://trailsyserver-prod.herokuapp.com/trailheads.json?loc=41.1,-81.5](http://trailsyserver-prod.herokuapp.com/trailheads.json?loc=41.1,-81.5)
 - [http://trailsyserver-prod.herokuapp.com/trailsegments.json](http://trailsyserver-prod.herokuapp.com/trailsegments.json)
