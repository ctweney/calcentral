'use strict';

var angular = require('angular');

/**
 * Finaid Activity controller for messages before 2016
 */
angular.module('calcentral.controllers').controller('FinaidActivityOldController', function(activityFactory, apiService, $scope) {
  var getFinaidActivityOld = function() {
    $scope.activityInfo = {
      isLoading: true
    };
    activityFactory.getFinaidActivityOld().then(function(data) {
      apiService.updatedFeeds.feedLoaded(data);
      angular.extend($scope, data);
      $scope.activityInfo.isLoading = false;
    });
  };

  getFinaidActivityOld();
});
