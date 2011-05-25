assert  = require 'assert'
backend = require('../src/backends/sqlite').create()

calls = 0

# no messages
backend.peek (err, obj) ->
	calls += 1
	assert.equal null, err
	assert.equal null, obj

process.on 'exit', ->
	assert.equal 1, calls
