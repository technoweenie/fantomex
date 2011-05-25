Sqlite3 = require('sqlite3').verbose()

exports.create = (options) ->
  new Backend options or {}
	
class Backend
  constructor: (options) ->
    @db = new Sqlite3.Database options.path || ':memory:'
    @setup()

  # Gets the earliest message.
  peek: (cb) ->
    sql = "SELECT rowid AS id, data FROM messages ORDER BY rowid LIMIT 1"
    @db.get sql, cb

  setup: ->
    @db.serialize =>
      @db.run "CREATE TABLE messages (data TEXT)"

