assert  = require 'assert'
backend = require('../src/backends/sqlite').create()

calls = 0

# no messages
backend.peek (err, obj) ->
  calls += 1
  assert.equal null, err
  assert.equal null, obj

backend.count (err, num) ->
  calls += 1
  assert.equal 0, num

backend.push "booya"

backend.peek (err, obj) ->
  calls += 1
  assert.equal null, err
  assert.ok    obj.id
  assert.equal "booya", obj.data

backend.count (err, num) ->
  calls += 1
  assert.equal 1, num

process.on 'exit', ->
  assert.equal 4, calls
