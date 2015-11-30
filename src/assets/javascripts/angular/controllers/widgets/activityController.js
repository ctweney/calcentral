'use strict';

var angular = require('angular');

/**
 * Activity controller
 */
angular.module('calcentral.controllers').controller('ActivityController', function(activityFactory, apiService, dateService, $scope) {
  var getMyActivity = function(options) {
    $scope.activityInfo = {
      isLoading: true
    };
    activityFactory.getActivity(options).then(function(data) {
      apiService.updatedFeeds.feedLoaded(data);
      angular.extend($scope, data);
      $scope.activityInfo.isLoading = false;
    });
  };

  $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
    if (services && services['MyActivities::Merged']) {
      getMyActivity({
        refreshCache: true
      });
    }
  });
  getMyActivity();
});
