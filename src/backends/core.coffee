EventEmitter = require('events').EventEmitter

class module.exports
  constructor: (options) ->
    @setup()
    @events = new EventEmitter

  on: (event, listener) ->
    @events.on event, listener

  emit: (event, args...) ->
    @events.emit event, args...

  setup: ->
