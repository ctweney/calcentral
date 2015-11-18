'use strict';

var angular = require('angular');

/**
 * Controller links student account with the requested delegate account
 */
angular.module('calcentral.controllers').controller('DelegateLinkingController', function(apiService, delegateFactory, $scope) {
  angular.extend($scope, {
    currentObject: {},
    isSaving: false
  });

  $scope.save = function(item) {
    apiService.delegate.save($scope, delegateFactory.linkAccounts, {
      securityKey: item.securityKey,
      proxyEmailAddress: item.proxyEmailAddress,
      agreeToTerms: item.agreeToTerms
    }).then(saveCompleted);
  };

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    apiService.delegate.actionCompleted(data).then(showLinkedStudents, function(errorMessage) {
      $scope.errorMessage = errorMessage;
    });
  };

  var showLinkedStudents = function() {
    // TODO: We're waiting on design and text, SISRP-11142
  };

  $scope.getTermsAndConditions = function() {
    delegateFactory.getTermsAndConditions().success(function(data) {
      angular.extend($scope, data);
      $scope.showTermsAndConditions = true;
    }).error(function() {
      $scope.displayError = 'failure';
    });
  };
});
