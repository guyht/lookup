# Wrapper to make spawns easier
spawn = require('child_process').spawn
log = require('glogger')('TANT-SPAWN')

# Utility to spawn a child process
module.exports = spawn_child = (cmd, args, opt, cb) ->

    log.info "Spawning child"

    sp = spawn(cmd, args, opt)

    sp.stdout.on 'data', (data) ->
        log.info "STDOUT: #{data}"

    sp.stderr.on 'data', (data) ->
        log.error "STDERR: #{data}"

    sp.on 'close', (code) ->
        log.info "Process exited with code #{code}"
        cb null, code
