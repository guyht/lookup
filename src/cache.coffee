# LookupDB cache handling

log = require('glogger')('LOOKUP-DB-CACHE')

redis = require 'redis'

# Setup redis client
redis_conf = (
    port: process.env.REDIS_PORT_6397_TCP_PORT || 6379
    host: process.env.REDIS_PORT_6379_TCP_ADDR || ''
)
client = redis.createClient redis_conf.port, redis_conf.host

cache_key = 'LKDB'

exports.set = (key, val) ->
    log.info "Setting #{key}"
    client.set "#{cache_key}-#{key}", val
    client.expire "#{cache_key}-#{key}", 60*60*26

exports.get = (key, cb) ->
    log.info "Getting #{key}"
    client.get "#{cache_key}-#{key}", cb


# Stats
# Queries
# Cache hits
# (Cache misses can be derrived from cache hits)
# Popular queries
exports.stats = (
    query: ->
        client.incr 'STAT-queries'

    cacheHit: ->
        client.incr 'STAT-cache-hit'

    term: (t) ->
        client.incr 'STAT-TERM-' + t

    get: (cb) ->
        client.get 'STAT-queries', (err, queries) ->
            client.get 'STAT-cache-hit', (err, hits) ->
                cb null, (queries: queries, hits: hits, misses: (queries-hits), hitp: ((hits / queries)*100))
)
