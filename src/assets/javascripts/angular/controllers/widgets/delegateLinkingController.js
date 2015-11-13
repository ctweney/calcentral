'use strict';

var angular = require('angular');

/**
 * Controller links student account with the requested delegate account
 */
angular.module('calcentral.controllers').controller('DelegateLinkingController', function(delegateLinkingFactory, $scope) {
  $scope.getTermsAndConditions = function() {
    delegateLinkingFactory.getTermsAndConditions().success(function(data) {
      angular.extend($scope, data);
      $scope.showTermsAndConditions = true;
    }).error(function() {
      $scope.displayError = 'failure';
    });
  };
});
