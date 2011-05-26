EventEmitter = require('events').EventEmitter

class module.exports
  constructor: (options) ->
    @setup()
    @events  = new EventEmitter
    @polling = false
    @timer   = null

  on: (event, listener) ->
    @events.on event, listener
    if @events.listeners(event).length == 1
      @events.on 'incoming', =>
        clearTimeout @timer if @timer
        @poll()
    @poll()

  emit: (event, args...) ->
    @events.emit event, args...

  poll: ->
    return if @polling
    @polling = true
    @peek (err, obj) =>
      if err
        @emit 'error', err
      else
        if obj
          @emit 'message', obj.data, (err) =>
            if err
              @emit 'error', err

            # temporarily remove errored messages until we can retry
            @remove obj.id, =>
              @polling = false
              @poll()
        else
          @poll_in 1

  poll_in: (sec) ->
    @polling = false
    @timer = setTimeout =>
      @poll()
    , sec * 1000

  setup: ->
