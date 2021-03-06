fetchValue = require "../../../../core/fetch/value.js"

module.exports = (vars, data) ->

  stacked  = vars.axes.stacked
  flip     = vars[stacked].scale.viz 0
  scale    = vars[stacked].scale.value
  opposite = if stacked is "x" then "y" else "x"
  margin   = if stacked is "y" then vars.axes.margin.top else vars.axes.margin.left
  offset   = if scale is "share" then "expand" else "zero"

  stack = d3.layout.stack()
    .values (d) -> d.values
    .offset offset
    .x (d) -> d.d3plus[opposite]
    .y (d) -> flip - vars[stacked].scale.viz fetchValue vars, d, vars[stacked].value
    .out (d, y0, y) ->

      value    = fetchValue vars, d, vars[stacked].value
      negative = value < 0

      if scale is "share"
        d.d3plus[stacked+"0"] = (1 - y0) * flip
        d.d3plus[stacked]     = d.d3plus[stacked+"0"] - (y * flip)
      else
        d.d3plus[stacked+"0"] = flip - y0
        d.d3plus[stacked]     = d.d3plus[stacked+"0"] - y

      d.d3plus[stacked]     += margin
      d.d3plus[stacked+"0"] += margin

  positiveData = data.filter (d) ->
    fetchValue(vars, d, vars[stacked].value) > 0
  negativeData = data.filter (d) ->
    fetchValue(vars, d, vars[stacked].value) < 0

  positiveData = stack positiveData if positiveData.length
  negativeData = stack negativeData if negativeData.length

  positiveData.concat(negativeData)
