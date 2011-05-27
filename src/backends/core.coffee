EventEmitter = require('events').EventEmitter

# Serves as a superclass for all Fantomex queues.
class module.exports
  constructor: (options) ->
    @setup()
    @events  = new EventEmitter
    @polling = false
    @timer   = null

  # Public: Attaches a listener to an event.
  #
  # event - A String event name.
  #         "message"  - The latest message from the queue, ready to be
  #                      processed.
  #         "incoming" - Internal message indicating a new message was
  #                      just added to the queue.
  #
  # Returns nothing.
  on: (event, listener) ->
    @events.on event, listener
    if @events.listeners(event).length == 1
      @events.on 'incoming', =>
        clearTimeout @timer if @timer
        @poll()
    @poll()

  # Starts the polling by pulling out the latest value in the queue.  If no
  # value is in the queue, sleep for 1 second and try, try again.
  #
  # Emits ("message", msg, next)
  #   msg       - The String contents of the message.
  #   next(err) - A Function callback to be called when the message is done.
  #               err - Optional error object.
  #
  # Returns nothing.
  poll: (from)->
    return if @polling
    @polling = true
    @peek (err, obj) =>
      if err
        @events.emit 'error', err
      else
        if obj
          @events.emit 'message', obj.data, (err) =>
            if err
              @reschedule obj, null, (err) =>
                @polling = false
                @poll()
            else
              @remove obj.id, =>
                @polling = false
                @poll()
        else
          @poll_in 1

  # Sleeps and retries the polling.
  #
  # sec - Integer specifying how many seconds to sleep.
  #
  # Returns nothing.
  poll_in: (sec) ->
    @polling = false
    @timer = setTimeout =>
      @poll()
    , sec * 1000

  # Placeholder that should be overridden.
  setup: ->
