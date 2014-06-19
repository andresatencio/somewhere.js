'use strict'

fs = require 'fs'

databasePath = ''
database = {}

_uuid = ->
  date = new Date().getTime()
  uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
    r = (date + Math.random() * 16) % 16 | 0
    date = Math.floor date/16
    v = if c is 'x' then r else r & 7 | 8
    v.toString 16

_checkCollection = (collection) ->
  return if database[collection]
  database[collection] = []

_filter = (obj, predicate) ->
  result = []
  result.push(item) for item in obj when predicate item
  result

_filterOne = (obj, predicate) ->
  return item for item in obj when predicate item

_matches = (attrs) ->
  (obj) ->
    return false for key, val of attrs when attrs[key] isnt obj[key]
    true

module.exports =
  connect: (path) ->
    databasePath = path
    if fs.existsSync databasePath
      database = JSON.parse fs.readFileSync(databasePath, 'utf-8')
    do @write

  clear: ->
    fs.unlinkSync databasePath

  write: ->
    fs.writeFileSync databasePath, JSON.stringify database

  save: (collection, data) ->
    _checkCollection collection
    data.id = do _uuid
    database[collection].push data
    do @write
    data

  findOne: (collection, attrs) ->
    _filterOne database[collection], _matches attrs

  find: (collection, attrs) ->
    return database[collection] if !attrs
    _filter database[collection], _matches attrs

  update: (collection, id, attrs) ->
    data = item for item in database[collection] when item.id is id
    data[key] = val for key, val of attrs
    do @write
    data

  remove: (collection, id) ->
    index = database[collection].indexOf(item) for item in database[collection] when item.id is id
    database[collection].splice index, 1 if index > -1
    do @write