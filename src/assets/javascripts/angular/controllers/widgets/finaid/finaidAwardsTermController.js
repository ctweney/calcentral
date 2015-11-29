'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Financial Aid - Awards controller
 */
angular.module('calcentral.controllers').controller('FinaidAwardsTermController', function($routeParams, $scope, finaidFactory) {
  $scope.finaidAwardsTerm = {
    isLoading: true,
    feed: {}
  };

  var loadAwardsTerm = function() {
    return finaidFactory.getAwardsTerm({
      finaidYearId: $routeParams.finaidYearId
    }).success(function(data) {
      angular.extend($scope.finaidAwardsTerm.feed, _.get(data, 'feed'));
      $scope.errored = data.errored;
      $scope.finaidAwardsTerm.isLoading = false;
    });
  };

  loadAwardsTerm();
  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadAwardsTerm);
});
