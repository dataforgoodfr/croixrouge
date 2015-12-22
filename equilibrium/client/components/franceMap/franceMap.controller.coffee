class franceMapCtrl

  @$inject: ['d3','d3UtilsService','HomeService','$state','DptService','$q']
  constructor: (d3, d3UtilsService,HomeService,@$state,DptService, $q) ->
    dptIndice = {
      '01': 86.366268840251678,
      '02': 90.226720474919375,
      '04': 86.381103010404715,
      '05': 87.050417897018093,
      '06': 86.169650372148809,
      '08': 80.477196481557414,
      '09': 89.633165974558935,
      '10': 87.294748542507079,
      '12': 86.156606484222905,
      '13': 87.777771685749201,
      '14': 87.628896541241318,
      '16': 80.576920270618587,
      '17': 87.166641576620393,
      '19': 89.378321803273863,
      '20': 90.733848348935226,
      '22': 87.590786273158656,
      '23': 86.667133388609997,
      '24': 89.712332347018346,
      '27': 86.478234879818245,
      '30': 86.637880255016285,
      '32': 86.06060929831574,
      '33': 86.117340793765692,
      '35': 85.506434414103921,
      '37': 86.025015687968803,
      '38': 88.120427568114039,
      '39': 87.427077938739998,
      '40': 88.136480713283319,
      '42': 87.916046383086041,
      '43': 90.017122149060981,
      '44': 86.4523767882134,
      '45': 79.320181692815623,
      '46': 90.507681566832261,
      '47': 90.773284653547691,
      '49': 88.793698662062226,
      '50': 85.087910184095492,
      '52': 88.784284664820461,
      '56': 84.386022718035136,
      '57': 90.169862928469882,
      '59': 87.468556819699984,
      '60': 87.251414478542486,
      '61': 89.596070150251165,
      '62': 84.965775106689549,
      '69': 88.467546007414398,
      '70': 88.413714857591458,
      '71': 89.57572721443043,
      '74': 87.166462815516667,
      '75': 87.455685322361546,
      '77': 89.789328868976185,
      '78': 88.799717146085555,
      '79': 86.16999433235766,
      '80': 87.432735778478516,
      '81': 90.495058731627665,
      '82': 89.198949227987228,
      '83': 87.800978480758332,
      '85': 80.951899319359526,
      '86': 90.079498819652386,
      '87': 88.107622493677766,
      '88': 88.521537544552729,
      '89': 86.160155455593625,
      '90': 89.257444018956136,
      '91': 89.822431485247762,
      '92': 85.969839362689157,
      '93': 86.796562514757923,
      '95': 88.105374167607707
      }

    mapW = 750
    mapH = 600
    scale = 4

    projection = d3.geo.mercator()
      .scale(2300)
      .translate([mapW / (scale - 1) , scale * mapH])
    path = d3.geo.path()
      .projection(projection)

    scaleIdf = 15000

    projectionIdf = d3.geo.mercator()
      .scale(scaleIdf)
      .translate([scaleIdf / 100000 , scaleIdf - 230])
    pathIdf = d3.geo.path()
      .projection(projectionIdf)


    svgMap = d3.select("div.france").append("svg")
      .attr("width",mapW)
      .attr("height",mapH)

    HomeService.getDpt()
    .then (res) ->
      svgMap.selectAll("path2").data([res.data.features[75],res.data.features[92],res.data.features[93],res.data.features[94]], (d) -> d.properties.code)
        .enter()
        .append("path")
        .on("click", (d) =>
          $state.go('departement',{id: d.properties.code}))
        .attr("fill", (d) =>
          "rgba(" + d3UtilsService.rgb(d3UtilsService.scaleScore(dptIndice[d.properties.code])) + ")")
        .attr("stroke-width", 1)
        .attr("stroke", "#353535")
        .attr("class", "map-dpt")
        .attr("d", pathIdf)
      svgMap.selectAll("path").data(res.data.features, (d) -> d.properties.code)
        .enter()
        .append("path")
        .on("click", (d) =>
          $state.go('departement',{id: d.properties.code}))
        .attr("fill", (d) =>
          "rgba(" + d3UtilsService.rgb(d3UtilsService.scaleScore(dptIndice[d.properties.code])) + ")")
        .attr("stroke-width", 1)
        .attr("stroke", "#353535")
        .attr("class", "map-dpt")
        .attr("d", path)


do (app = angular.module 'components.franceMap.controller', []) ->
  app.controller 'franceMapCtrl', franceMapCtrl

    

