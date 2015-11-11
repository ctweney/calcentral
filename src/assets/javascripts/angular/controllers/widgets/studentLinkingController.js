'use strict';

var angular = require('angular');

/**
 * Controller links student account with the requested delegate account
 */
angular.module('calcentral.controllers').controller('StudentLinkingController', function(studentLinkingFactory, $scope) {
  $scope.linkAccounts = function() {
    return studentLinkingFactory.linkAccounts().success(function(data) {
      angular.extend($scope, data);
    }).error(function() {
      $scope.displayError = 'failure';
    });
  };

  var loadStudentLinkingCard = function() {
    $scope.termsAndConditions = studentLinkingFactory.termsAndConditions();
  };

  loadStudentLinkingCard();
});

