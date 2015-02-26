# Lookup DB
#

# Dependencies
log = require('glogger')('LOOKUP-DB')
express = require 'express'
server = require('http')
socket = require('socket.io')
ansi_up = require 'ansi_up'

spawn = require './spawn_child'
cache = require './cache'

request = require 'superagent'
# Express modules
bp = require 'body-parser'

api_base = 'https://loom.shalott.org/api/sequell/ldb'

# Choose port
port = process.env.PORT || 8080

log.info "Loading app on port #{port}"

# Load up app
app = express()
ser = server.Server app
io = socket ser
app.use bp.urlencoded()
app.use(express.static('./public'))


# Setup socket route for API
io.on 'connection', (sock) ->
    log.info "Handling socket.io connection"

    # Send stat data on initial connection
    cache.stats.get (err, data) ->
        if err or !data then return
        log.info "Sending stats"
        io.emit 'stats', data

    sock.on 'lookup', (query, cb) ->
        # Get data from API
        log.info "Looking up #{query}"
        lookup query, (err, data) ->

            # Trigger callback
            cb null, data


        # Now we have sent back the data, we also want to emmit
        # the new stats
        cache.stats.get (err, data) ->
            if err or !data then return
            log.info "Sending stats"
            io.emit 'stats', data

    # Send number of connected clients
    # Do this on connection and disconnect
    log.info  io.engine.clientsCount + ' clients connected'
    sock.on 'disconnect', ->
        log.info "Client disconnected"
        log.info  io.engine.clientsCount + ' clients connected'


# This is a 1 page shop, so just do a catchall
app.all '/', (req, res) ->
    log.info "Serving request"
    res.render 'index.jade'

app.all '/stat', (req, res) ->
    cache.stats.get (err, data) ->
        res.json data


# Func to lookup
lookup = (query, cb) ->

    # Register query hit
    cache.stats.query()

    # Check cache
    cache.get query, (err, data) ->
        if data
            # Cache hit
            log.info "Cache HIT"

            # Save stats
            cache.stats.cacheHit()

            cache.stats.term query
            cb null, JSON.parse data

        else # Cache miss
            log.info "Cache MISS"

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

                    # If 404, then we had no result
                    if data.status is 404
                        log.info "404 status - no result"
                        return cb null, (definitions: [])


                    # Lookup monster
                    spawn './monster-trunk', [query], {}, (err, monster) ->
                        log.debug monster

                        # If err or null, return now
                        if err or !monster
                            log.error "Oops, something bad happened :("
                            return cb true, null

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
                        cache.stats.term query
                        cache.set query, JSON.stringify re

                        # Send back to the client
                        cb null, re


ser.listen port

# for testing
module.exports = app
