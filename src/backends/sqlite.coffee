Sqlite3 = require('sqlite3').verbose()
Backend = require './core'

# Creates a sqlite Fantomex queue.
#
# options - Hash of options to configure the queue instance.
#           path: The String path to the sqlite database.
#                 Default: :memory:
#
# Returns a sqlite queue instance.
exports.create = (options) ->
  new SqliteBackend options or {}
	
class SqliteBackend extends Backend
  constructor: (options) ->
    @db = new Sqlite3.Database options.path || ':memory:'
    super()

  # Public: Adds a new message to the queue.
  #
  # msg      - The String message.
  # cb(err)  - Optional Function callback that is called after the message
  #            has been saved.
  #            err - The optional error object.
  #
  # Emits ("incoming")
  #
  # Returns nothing.
  push: (msg, cb) ->
    @db.run "INSERT INTO messages VALUES (?)", msg.toString(), (args...) =>
      @events.emit 'incoming'
      cb?(args...)

  # Gets the earliest message.
  #
  # cb(err, row) - Function callback that is called with the queue object.
  #                err - Optional error object.
  #                row - Object with 'id' and 'data' properties.
  #
  # Returns nothing.
  peek: (cb) ->
    sql = "SELECT rowid AS id, data FROM messages ORDER BY rowid LIMIT 1"
    @db.get sql, cb

  # Counts the messages in the queue.
  #
  # cb(err, num) - Function callback that is called with the count.
  #                err - Optional error object.
  #                num - Integer of the number of messages.
  #
  # Returns nothing.
  count: (cb) ->
    @db.get "SELECT COUNT(rowid) as count FROM messages", (err, row) ->
      if err
        cb(err)
      else
        cb null, row.count

  # Removes a message from the queue.
  #
  # id      - Integer ID of the message.
  # cb(err) - Function callback that is called after the deletion.
  #           err - Optional error object.
  #
  # Returns nothing.
  remove: (id, cb) ->
    @db.run "DELETE FROM messages WHERE rowid = ?", id, cb

  # Ensures the queries in the given callback are run in a single batch.
  #
  # cb - Function callback containing the batched queries.
  #
  # Returns nothing.
  transaction: (cb) ->
    @db.serialize cb

  # Sets up the sqlite table.
  #
  # Returns nothing.
  setup: ->
    @db.serialize =>
      @db.run "CREATE TABLE messages (data TEXT)"

