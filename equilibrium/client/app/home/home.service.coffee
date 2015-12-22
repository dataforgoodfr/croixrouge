do (app = angular.module 'cr.home.service', []) ->
  app.factory 'HomeService', ($http)->
    new class HomeService
      constructor: ()->
        @dpt = []

      getDpt: ()->
        onSuccess = (success) =>
          @dpt = success
        $http.get('../assets/data/departements.geojson').then onSuccess
      getBestCenters: () ->
        onSuccess = (success) =>
          success.data
        $http.get('../assets/data/bestCenters.json').then onSuccess
      getWorstCenters: () ->
        onSuccess = (success) =>
          success.data
        $http.get('../assets/data/worstCenters.json').then onSuccess
