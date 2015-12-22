class HomeCtrl

  @$inject: ['HomeService','d3UtilsService']
  constructor: (HomeService, @d3UtilsService) ->
    HomeService.getBestCenters()
    .then (res) =>
      @bestCenters = res
    HomeService.getWorstCenters()
    .then (res) =>
      @worstCenters = res



    

do (app = angular.module 'cr.home.controller', []) ->
  app.controller 'HomeCtrl', HomeCtrl

    

