# tasker
# Connects to PULL socket on tcp://*:5555
# Pushes a flurry of jobs

port  = process.env.PORT or 5555
jobs  = process.env.NUM or 1000

context = require 'zeromq'
socket = context.createSocket 'push'
socket.connect "tcp://127.0.0.1:#{port}"

payload = (new Buffer 100).toString("base64")
for num in [1..jobs]
  socket.send "#{num}:#{payload}"

socket.close()
