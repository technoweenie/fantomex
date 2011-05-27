# worker
# Binds PULL socket on tcp://*:5555
# Receives a flurry of jobs from the tasker.

port = process.env.PORT or 5555
if backend = process.env.BACKEND
  [type, path] = backend.split ':'
  backend = require('../src')[type]("path": path)

context = require 'zeromq'
socket = context.createSocket 'pull'

socket.on 'message', (buf) ->
  [num, payload] = buf.toString().split ':'
  backend.push num

backend.count (err, num) ->
  console.log num, 'messages already waiting'

backend?.on 'message', (msg, next) ->
  console.log msg
  setTimeout ->
    try
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
