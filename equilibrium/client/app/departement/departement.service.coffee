do (app = angular.module 'cr.departement.service', []) ->
  app.factory 'DptService', ($http)->
    new class DptService
      constructor: ()->


      getDptData: ()->
        onSuccess = (success) =>
          success.data
        $http.get('../assets/data/data2.json').then onSuccess

      getCentreData: (dptId,centreId) ->
        onSuccess = (success) =>
          success.data[dptId].centers[centreId]
        $http.get('../assets/data/data2.json').then onSuccess

      getCentreDataWeeks: (dptId,centreId) ->
        onSuccess = (success) =>
          success.data[dptId].centers[centreId].weeks
        $http.get('../assets/data/data2.json').then onSuccess

  
  
        



