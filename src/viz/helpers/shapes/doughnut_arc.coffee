shapeStyle  = require "./style.coffee"
largestRect = require "../../../geom/largestRect.coffee"
path2poly   = require "../../../geom/path2poly.coffee"

module.exports = (vars, selection, enter, exit) ->

  arc = d3.svg.arc()
    .innerRadius (d) -> d.d3plus.ir
    .outerRadius (d) -> d.d3plus.r
    .startAngle (d) -> d.d3plus.startAngle
    .endAngle (d) -> d.d3plus.endAngle

  # Calculate label position and pass data from parent.
  data = (d) ->
    if vars.labels.value
      if d.d3plus.label
        d.d3plus_label = d.d3plus.label
      else
        poly = path2poly(arc(d))
        rect = largestRect poly,
          angle: 0
        if rect[0]
          d.d3plus_label =
            w:         rect[0].width
            h:         rect[0].height
            x:         rect[0].cx
            y:         rect[0].cy
        else
          delete d.d3plus_label
    [d]

  if vars.draw.timing

    newarc = d3.svg.arc()
      .innerRadius (d) -> d.d3plus.ir
      .outerRadius (d) -> d.d3plus.r
      .startAngle (d) ->
        d.d3plus.startAngleCurrent = 0 if d.d3plus.startAngleCurrent is undefined
        d.d3plus.startAngleCurrent = d.d3plus.startAngle if isNaN(d.d3plus.startAngleCurrent)
        d.d3plus.startAngleCurrent
      .endAngle (d) ->
        d.d3plus.endAngleCurrent = 0 if d.d3plus.endAngleCurrent is undefined
        d.d3plus.endAngleCurrent = d.d3plus.endAngle if isNaN(d.d3plus.endAngleCurrent)
        d.d3plus.endAngleCurrent

    arcTween = (arcs, newAngle) ->
      arcs.attrTween "d", (d) ->

        if newAngle is undefined
          s = d.d3plus.startAngle
          e = d.d3plus.endAngle
        else if newAngle is 0
          s = 0
          e = 0

        interpolateS = d3.interpolate(d.d3plus.startAngleCurrent, s)
        interpolateE = d3.interpolate(d.d3plus.endAngleCurrent, e)
        (t) ->
          d.d3plus.startAngleCurrent = interpolateS(t)
          d.d3plus.endAngleCurrent   = interpolateE(t)
          newarc d

    enter.append("path")
      .attr "class", "d3plus_data"
      .call shapeStyle, vars
      .attr "d", newarc

    selection.selectAll("path.d3plus_data").data data
      .transition().duration vars.draw.timing
      .call shapeStyle, vars
      .call arcTween

    exit.selectAll("path.d3plus_data")
      .transition().duration vars.draw.timing
      .call arcTween, 0

  else

    enter.append("path").attr "class", "d3plus_data"

    selection.selectAll("path.d3plus_data").data data
      .call shapeStyle, vars
      .attr "d", arc

  return
