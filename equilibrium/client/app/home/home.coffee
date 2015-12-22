'use strict'
do ( app = angular.module 'cr.home', [
  'cr.home.controller'
  'cr.home.service'
]) ->

  app.config ['$stateProvider', ($stateProvider) ->
    $stateProvider
      .state 'home',
        url: '/'
        views:
          "":
            controller: 'HomeCtrl'
            controllerAs: 'home'
            templateUrl: 'app/home/home.html'
  ]