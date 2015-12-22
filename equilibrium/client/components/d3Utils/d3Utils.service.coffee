do (app = angular.module 'components.d3utils.service', []) ->
  app.factory 'd3UtilsService', (d3)->
    new class d3UtilsService
      constructor: ()->
        @scaleScore = d3.scale.linear()
          .domain([70.7,93])
          .range([0,100])

      rgb: (score) ->
        r = [250, 50, 50,1.0]
        y = [250, 250,50,1.0]
        g = [125, 250, 50,1.0]
        def = [211,211,211,1.0]

        if (score < 15) and ((score >= 0))
          r
        else if ((score > 42) and (score < 58))
          y
        else if (score > 85)
          g
        else if ((score >= 15) and (score <= 42))
          res = [250, Math.round(((score - 15) / (42 - 15)) * 200 + 50,0) , 50,1.0]
        else if ((score >= 58) && (score <= 85))
          res = [Math.round(( 1 - ((score - 58) / (85 - 58)) ) * 125 + 125,0), 250 , 50,1.0]
        else
          def

        