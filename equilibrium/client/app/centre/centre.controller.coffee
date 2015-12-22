class CentreCtrl

  @$inject: ['$state','$stateParams','DptService','d3','d3UtilsService','$document']
  constructor: ($state,$stateParams,DptService,d3,@d3UtilsService,$document) ->
    @service = DptService
    @dptId = $stateParams.dptId
    @centreId = $stateParams.centreId

    @service.getCentreData(@dptId,@centreId)
    .then (res) =>
      @name = res.name
      @repas = res.repas
      @score = @d3UtilsService.scaleScore(res.indice)
      equilibre = res.equilibre
      @data = @formatChartData(equilibre)

    @chartOptions = {
      axisX:{
        showGrid: false
      }
      axisY: {
        onlyInteger: true
        labelInterpolationFnc: (val) ->
          val + ' %'
      }
    }


    DptService.getCentreDataWeeks(@dptId,@centreId)
    .then (res) =>
      @weeks = res
      

      w = 1140
      h = 175
      rectW = 40
      space = 3

      week = []

      for k, v of @weeks
        week.push @d3UtilsService.scaleScore(v.indice)
        v.data = @formatChartData(v.equilibre)
      

      setCoord = (index) ->
        coord = []
        x = index %% 17
        if index <= 16
          coord = [index * (rectW + space),0] 
        else if index <= 33
          coord = [x * (rectW + space), 1 * (rectW + space)]
        else if index <= 50
          coord = [x * (rectW + space), 2 * (rectW + space)]
        else
          coord = [x * (rectW + space), 3 * (rectW + space)]
        coord
        

      svg = d3.select(".week").append("svg")
        .attr("width",w)
        .attr("height",h)

      svg.selectAll("rect").data(week)
        .enter()
        .append("rect")
        .attr("class","week-square")
        .attr("x", (d,i) -> setCoord(i)[0] )
        .attr('y',(d,i) -> setCoord(i)[1])
        .attr("width", rectW)
        .attr("height",rectW)
        .on("click", (d,i) =>
          if d != -1
            offset = 50
            duration = 300
            someElement = angular.element(document.getElementById('semaine' + (i + 1)))
            $document.scrollToElement(someElement, offset, duration)
        )
        .attr("fill", (d) => "rgba(" + @d3UtilsService.rgb(d) + ")" )
        

      svg.selectAll("text").data(week)
        .enter()
        .append("text")
        .attr("class","week-square")
        .on("click", (d,i) =>
          if d != -1
            offset = 50
            duration = 300
            someElement = angular.element(document.getElementById('semaine' + (i + 1)))
            $document.scrollToElement(someElement, offset, duration)
        )
        .text((d,i) -> i + 1)
        .attr("x", (d,i) -> setCoord(i)[0] + rectW / 2)
        .attr('y', (d,i) -> setCoord(i)[1] + rectW / 2 + 5)
        .attr('font-size',14)
        .attr('text-anchor','middle')

  formatChartData: (equilibre) ->
    actual = []
    ideal = []
    labels = []
    for k,v of equilibre
        actual.push v.actual
        ideal.push v.ideal
        labels.push v.name
    data = {
      "labels": labels,
      "series": [ ideal, actual]
    }
    data

    
    

do (app = angular.module 'cr.centre.controller', []) ->
  app.controller 'CentreCtrl', CentreCtrl

    

