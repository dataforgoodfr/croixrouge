class DptCtrl

  @$inject: ['$state','$stateParams','DptService','d3UtilsService']
  constructor: ($state,$stateParams,@DptService,@d3UtilsService) ->
    @service = @DptService
    @dptId = $stateParams.id
    
    @DptService.getDptData()
    .then (res) =>
      @name = res[@dptId].name
      @repas = res[@dptId].repas
      @score = @d3UtilsService.scaleScore(res[@dptId].indice)
      @key = @dptId
      @centres = res[@dptId].centers
      equilibre = res[@dptId].equilibre
      actual = []
      ideal = []
      labels = []
      for k,v of equilibre
        console.log v
        actual.push v.actual
        ideal.push v.ideal
        labels.push v.name
      @data = {
        "labels": labels,
        "series": [ ideal, actual]
      }

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
        
      


      
    
    

do (app = angular.module 'cr.departement.controller', []) ->
  app.controller 'DptCtrl', DptCtrl

    

