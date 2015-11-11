'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Title 4 (finaid) controller
 */
angular.module('calcentral.controllers').controller('Title4Controller', function(finaidFactory, $rootScope, $scope) {
  $scope.title4 = {
    isLoading: true,
    showMessage: false
  };

  /**
   * Send an event to let everyone know the permissions have been updated.
   */
  var sendEvent = function() {
    $rootScope.$broadcast('calcentral.custom.api.finaid.approvals');
  };

  $scope.sendResponseT4 = function(response) {
    $scope.title4.isLoading = true;
    finaidFactory.postT4Response(response).then(sendEvent);
  };

  /**
   * Parse the finaid information
   */
  var parseFinaid = function(data) {
    angular.extend($scope.title4, {
      isApproved: _.get(data, 'feed.finaidSummary.title4.approved'),
      longMessage: _.get(data, 'feed.finaidSummary.title4.longMessage')
    });
  };

  /**
   * Get the finaid summary information
   */
  var getFinaidPermissions = function(options) {
    return finaidFactory.getSummary(options).success(function(data) {
      $scope.title4.hasFinaid = !!_.get(data, 'feed.finaidSummary.finaidYears.length');

      if ($scope.title4.hasFinaid) {
        parseFinaid(data);
      }

      $scope.title4.isLoading = false;
    });
  };

  getFinaidPermissions();

  /**
   * We need to update the finaid summary when the approvals have changed
   */
  $scope.$on('calcentral.custom.api.finaid.approvals', function() {
    getFinaidPermissions({
      refreshCache: true
    });
  });
});
