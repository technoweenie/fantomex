Sqlite3 = require('sqlite3').verbose()

exports.create = (options) ->
  new Backend options or {}
	
class Backend
  constructor: (options) ->
    @db = new Sqlite3.Database options.path || ':memory:'
    @setup()

  transaction: (cb) ->
    @db.serialize cb

  push: (msg, cb) ->
    @db.run "INSERT INTO messages VALUES (?)", msg.toString(), cb

  # Gets the earliest message.
  peek: (cb) ->
    sql = "SELECT rowid AS id, data FROM messages ORDER BY rowid LIMIT 1"
    @db.get sql, cb

  count: (cb) ->
    @db.get "SELECT COUNT(rowid) as count FROM messages", (err, row) ->
      if err
        cb(err)
      else
        cb null, row.count

  remove: (id, cb) ->
    @db.run "DELETE FROM messages WHERE rowid = ?", id, cb

  setup: ->
    @db.serialize =>
      @db.run "CREATE TABLE messages (data TEXT)"

