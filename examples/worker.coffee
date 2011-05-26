# worker
# Binds PULL socket on tcp://*:5555
# Receives a flurry of jobs from the tasker.

port = process.env.PORT or 5555
if backend = process.env.BACKEND
  [type, path] = backend.split ':'
  backend = require('../src')[type]("path": path)

context = require 'zeromq'
socket = context.createSocket 'pull'

countdown = 0
sleep     = 0
socket.on 'message', (buf) ->
  [command,num,extra] = buf.toString().split(":")
  if command == 'start'
    countdown = parseInt num
    sleep     = parseInt extra
    console.time "#{num} messages"
  else
    backend?.push buf

    setTimeout ->
      if countdown < 2
        console.timeEnd "#{num} messages"
        backend?.count (err, num) ->
          console.log err or num
      else
        countdown -= 1
    , sleep

socket.bindSync "tcp://*:#{port}"
console.log "Listening..."

process.on 'SIGINT', ->
  console.log "Hanging it up..."
  backend
  socket.close()
