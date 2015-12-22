'use strict'
do ( app = angular.module 'cr.centre', [
  'cr.centre.controller'
]) ->

  app.config ['$stateProvider', ($stateProvider) ->
    $stateProvider
      .state 'centre',
        url: '/departement/:dptId/centre/:centreId'
        views:
          "":
            controller: 'CentreCtrl'
            controllerAs: 'centre'
            templateUrl: 'app/centre/centre.html'
  ]