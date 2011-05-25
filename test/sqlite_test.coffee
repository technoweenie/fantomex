assert  = require 'assert'
backend = require('../src/backends/sqlite').create()

calls = 0

# no messages
backend.peek (err, obj) ->
  calls += 1
  assert.equal null, err
  assert.equal null, obj

backend.push "booya"

backend.peek (err, obj) ->
  calls += 1
  assert.equal null, err
  assert.ok    obj.id
  assert.equal "booya", obj.data

process.on 'exit', ->
  assert.equal 2, calls
