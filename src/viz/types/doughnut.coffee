comparator    = require "../../array/comparator.coffee"
dataThreshold = require("../../core/data/threshold.js")
fetchValue    = require("../../core/fetch/value.js")
groupData     = require("../../core/data/group.coffee")

order = {}

doughnut = (vars) ->

  doughnutLayout = d3.layout.pie()
    .value (d) -> d.value
    .sort (a, b) ->
      if vars.order.value
        comparator a.d3plus, b.d3plus, [vars.order.value], vars.order.sort.value, [], vars
      else
        aID = fetchValue vars, a.d3plus, vars.id.value
        order[aID] = a.value if order[aID] is undefined
        bID = fetchValue vars, b.d3plus, vars.id.value
        order[bID] = b.value if order[bID] is undefined
        if order[bID] < order[aID] then -1 else 1

  groupedData = groupData vars, vars.data.viz, []
  doughnutData     = doughnutLayout groupedData
  returnData  = []

  radius = d3.min([vars.width.viz, vars.height.viz])/2 - vars.labels.padding * 2
  innerRadius = radius*0.45;

  for d in doughnutData

    item = d.data.d3plus
    item.d3plus.startAngle = d.startAngle
    item.d3plus.endAngle   = d.endAngle
    item.d3plus.r          = radius
    item.d3plus.ir = innerRadius
    item.d3plus.x = vars.width.viz/2
    item.d3plus.y          = vars.height.viz/2

    returnData.push item

  returnData

# Visualization Settings and Helper Functions
doughnut.filter       = dataThreshold
doughnut.requirements = ["data", "size"]
doughnut.shapes       = ["doughnut_arc"]
doughnut.threshold    = (vars) -> (40 * 40) / (vars.width.viz * vars.height.viz)
doughnut.tooltip      = "follow"
module.exports   = doughnut
