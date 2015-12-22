'use strict'

angular.module 'crApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ui.router',
  'ui.bootstrap',
  'duScroll'
  'angular-chartist'

  'd3'

  'cr.home'
  'cr.departement'
  'cr.centre'

  'components.franceMap'
  'components.d3Utils'
]
.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider
  .otherwise '/'

  $locationProvider.html5Mode true
