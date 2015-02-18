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
                log.error err
                return cb err

            log.info "Got good response from server - #{data.status}"
            log.debug data.text


            # Lookup monster
            spawn './monster-trunk', [query], {}, (err, monster) ->
                log.debug monster


                # Add to cache
                re = data.body
                re.monster = ansi_up.ansi_to_html monster.toString()
                cache[query] = re
                cb null, cache[query]



ser.listen port

# for testing
module.exports = app
