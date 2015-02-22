# Lookup DB
#

# Dependencies
log = require('glogger')('LOOKUP-DB')
express = require 'express'
server = require('http')
socket = require('socket.io')
spawn = require './spawn_child'
ansi_up = require 'ansi_up'

request = require 'superagent'
# Express modules
bp = require 'body-parser'

api_base = 'https://loom.shalott.org/api/sequell/ldb'

# Choose port
port = process.env.PORT || 8080

log.info "Loading app on port #{port}"

# Basic cache
cache = {}

# Load up app
app = express()
ser = server.Server app
io = socket ser
app.use bp.urlencoded()
app.use(express.static('./public'))


# Setup socket route for API
io.on 'connection', (sock) ->
    log.info "Handling socket.io connection"

    sock.on 'lookup', (query, cb) ->
        # Get data from API
        log.info "Looking up #{query}"
        lookup query, (err, data) ->
            cb null, data

# This is a 1 page shop, so just do a catchall
app.all '/', (req, res) ->
    log.info "Serving request"
    res.render 'index.jade'


# Func to lookup
lookup = (query, cb) ->
    # If cached, return now
    if cache[query]? then return cb null, cache[query]

    # Not cached, look it up
    request.get api_base
        .query (term: query)
        .end (err, data) ->
            if err
                # Generally means not found (for some reason we dont return JSON here... this is a bug really)
                log.error "Error occured making request to learndb API"
                log.error err
                return cb err

            log.info "Got good response from server - #{data.status}"
            log.debug data.text


            # Lookup monster
            spawn './monster-trunk', [query], {}, (err, monster) ->
                log.debug monster

                # Lets have a string
                monsterStr = monster.toString()

                # Setup an object we can send back to the client
                re = data.body

                # Was monster found?
                if monsterStr.match 'unknown monster:'
                    # Return a null value
                    re.monster = null
                else
                    # Add the monster and render the console escape codes to html
                    re.monster = ansi_up.ansi_to_html monsterStr

                # Cache the result
                cache[query] = re

                # Send back to the client
                cb null, cache[query]



ser.listen port

# for testing
module.exports = app
