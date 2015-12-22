'use strict'
do ( app = angular.module 'cr.departement', [
  'cr.departement.controller'
  'cr.departement.service'
]) ->

  app.config ['$stateProvider', ($stateProvider) ->
    $stateProvider
      .state 'departement',
        url: '/departement/:id'
        views:
          "":
            controller: 'DptCtrl'
            controllerAs: 'dpt'
            templateUrl: 'app/departement/departement.html'
  ]