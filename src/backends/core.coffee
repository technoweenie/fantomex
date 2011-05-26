EventEmitter = require('events').EventEmitter

class module.exports
  constructor: (options) ->
    @setup()
    @events  = new EventEmitter
    @polling = false

  on: (event, listener) ->
    @events.on event, listener
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
    setTimeout =>
      @poll()
    , sec * 1000

  setup: ->
