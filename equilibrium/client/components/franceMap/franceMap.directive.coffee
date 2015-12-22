do (app=angular.module 'components.franceMap.directive', [
  'components.franceMap.controller'
]) ->
  app.directive 'franceMap', ->
    restrict: 'E'
    templateUrl: 'components/franceMap/franceMap.html'
    controller: 'franceMapCtrl'
    controllerAs: 'franceMap'