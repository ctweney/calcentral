'use strict';

var angular = require('angular');

/**
 * Finaid Communications controller
 */
angular.module('calcentral.controllers').controller('FinaidCommunicationsController', function($scope, finaidFactory, finaidService) {
  $scope.communications = {
    isLoading: true
  };

  var loadCommunications = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).success(function(data) {
      angular.extend($scope.communications, data.feed.communications);
      $scope.errored = data.errored;
      $scope.communications.isLoading = false;
    });
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadCommunications);
});
