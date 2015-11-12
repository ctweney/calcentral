'use strict';

var angular = require('angular');

/**
 * Controller links student account with the requested delegate account
 */
angular.module('calcentral.controllers').controller('StudentLinkingController', function($scope) {
  $scope.getTermsAndConditions = function() {
    // TODO: Properly wire this into studentLinkingFactory
    $scope.agreement = {
      text: 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      showing: true
    };
  };
});
