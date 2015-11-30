'use strict';

var angular = require('angular');

/**
 * Finaid Communications controller
 */
angular.module('calcentral.controllers').controller('FinaidCommunicationsController', function($scope, activityFactory) {
  $scope.communicationsInfo = {
    isLoading: true
  };

  var getMyActivity = function(options) {
    $scope.activityInfo = {
      isLoading: true
    };
    return activityFactory.getFinaidActivity(options).then(function(data) {
      angular.extend($scope, data);
      $scope.activityInfo.isLoading = false;
    });
  };

  var loadCommunications = function() {
    getMyActivity().then(function() {
      $scope.communicationsInfo.isLoading = false;
    });
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadCommunications);
});
