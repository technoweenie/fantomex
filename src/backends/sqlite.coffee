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
    @db.run "INSERT INTO messages (data, retries) VALUES (?, 0)",
      msg.toString(), (args...) =>
        @events.emit 'incoming'
        cb?(args...)

  # Gets the earliest message.
  #
  # cb(err, row) - Function callback that is called with the queue object.
  #                err - Optional error object.
  #                row - Object with 'id', 'data', and 'retries' properties.
  #
  # Returns nothing.
  peek: (cb) ->
    sql = "SELECT rowid AS id, data, retries, run_at FROM messages
      ORDER BY run_at,rowid LIMIT 1"
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
  # cb(err) - Optional Function callback called if there is an error
  #           creating the table.
  #
  # Returns nothing.
  setup: (cb) ->
    @db.serialize =>
      @db.run "CREATE TABLE IF NOT EXISTS messages (
        data TEXT,
        retries INTEGER,
        run_at DATETIME DEFAULT CURRENT_TIMESTAMP)", (err) =>
          if err
            cb? err
            @events.emit 'error', err
      @db.run "CREATE INDEX IF NOT EXISTS messages_by_run_at ON messages (run_at)",
        (err) =>
          if err
            cb? err
            @events.emit 'error', err

