# Public: Creates a sqlite Fantomex queue.
#
# options - Hash of options to configure the queue instance.
#           path: The String path to the sqlite database.
#                 Default: :memory:
#
# Returns a sqlite queue instance.
exports.sqlite = (options) ->
  require('./backends/sqlite').create options

