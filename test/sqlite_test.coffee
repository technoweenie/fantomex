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
      testEvents()

testEvents = ->
  # only 1 error is expected.  throw any tohers.
  backend.on 'error', (err) ->
    calls += 1
    if err == 123
      backend.push 'count'
    else
      throw err

  backend.on 'message', (msg, next) ->
    calls += 1
    # message 1 tests the success case: the message is deleted from the
    # queue
    if msg == 'success'
      backend.push 'error'
      next()

    # message 2 tests the error case: the message is requeued at a later
    # time
    else if msg == 'error'
      next 123 # setting an error

    # message 3 is a test to check that the error job is still in the
    # queue.
    #
    # don't call next(), otherwise you'll continue the loop
    else if msg == 'count'
      backend.count (err, num) ->
        calls += 1
        assert.equal 1, num

    # unexpected!
    else
      assert.fail "Invalid Message: #{msg}"

  # get the ball rolling!
  backend.push 'success'

process.on 'exit', ->
  assert.equal 10, calls
