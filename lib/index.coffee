bean = require 'bean'

tableTemplate = require './table.jade'
rowTemplate = require './row.jade'

RowStream = require './row-stream.coffee'

stringToElement = (str) ->
  clean = str.replace /(^\s+)|(\s+$)/g, ''
  div = document.createElement 'div'
  div.innerHTML = clean

  els = div.childNodes

  if els.length is 1
    return els[0]
  else
    return els

createRowElement = (str) ->
  tr = document.createElement 'tr'
  tr.innerHTML = str
  return tr

module.exports = (columns, rowFn) ->
  normalizeColumns columns

  html = tableTemplate columns: columns

  $table = stringToElement html
  $tbody = $table.querySelector 'tbody'

  rowStream = RowStream columns

  rowStream.on 'data', (data) ->
    {cells, obj} = data
    html = rowTemplate cells: cells
    tr = createRowElement html
    rowFn obj, tr if rowFn
    $tbody.appendChild tr

  addSort $table

  rowStream.el = $table

  return rowStream

normalizeColumns = (columns) ->
  for column in columns
    column.title ?= column.property


addSort = (table) ->
  tbody = table.querySelector 'tbody'
  curSort = null
  reverse = false

  bean.on table, 'click', 'th', (event) ->
    el = this
    className = el.getAttribute 'class'
    rows = [] 
    rows.push el for el in tbody.childNodes

    if className is curSort
      reverse = not reverse
    else
      reverse = false

    rows.sort (a, b) ->
      [av, bv] = [a, b].map (cell) ->

        val = cell.querySelector('.'+className).dataset.value
        try
          return JSON.parse val
        catch err
          return val
      
      if reverse
        r = -1
      else
        r = 1

      return 1*r if av > bv
      return -1*r if bv > av
      return 0

    curSort = className

    tbody.innerHTML = ''
    for row in rows
      tbody.appendChild row