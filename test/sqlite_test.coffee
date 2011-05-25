assert  = require 'assert'
backend = require('../src/backends/sqlite').create()

calls = 0

backend.transaction ->
  # no messages
  backend.peek (err, obj) ->
    calls += 1
    assert.equal null, err
    assert.equal null, obj

  # no messages
  backend.count (err, num) ->
    calls += 1
    assert.equal 0, num

  # add a message
  backend.push "booya"

  # now it's visible
  obj_id = null
  backend.peek (err, obj) ->
    calls += 1
    assert.equal null, err
    assert.ok    obj.id
    obj_id = obj.id

  # and it's counted
  backend.count (err, num) ->
    calls += 1
    assert.equal 1, num

    # remove the message :(
    backend.remove obj_id

    # not counted anymore
    backend.count (err, num) ->
      calls += 1
      assert.equal 0, num

process.on 'exit', ->
  assert.equal 5, calls
