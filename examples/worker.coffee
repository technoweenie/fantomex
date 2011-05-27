# worker
# Binds PULL socket on tcp://*:5555
# Receives a flurry of jobs from the tasker.

port = process.env.PORT or 5555

# load sqlite in memory by default
backend = process.env.BACKEND or 'sqlite'
[type, path] = backend.split ':'
backend = require('../src')[type]("path": path)

context = require 'zeromq'
socket = context.createSocket 'pull'

socket.on 'message', (buf) ->
  [num, payload] = buf.toString().split ':'
  backend.push num

backend.count (err, num) ->
  console.log num, 'messages already waiting'

backend.on 'message', (msg, next) ->
  console.log 'JOB:', msg
  setTimeout ->
    try
      if msg == '4'
        console.log 'exponential backoff', new Date
        throw 'boom'
      next()
    catch err
      next err
  , 10

socket.bindSync "tcp://*:#{port}"
console.log "Listening..."

process.on 'SIGINT', ->
  console.log "Hanging it up..."
  socket.close()
  process.exit()
