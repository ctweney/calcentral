'use strict';

var angular = require('angular');

/**
 * Controller for users wanting to manage delegates
 */
angular.module('calcentral.controllers').controller('DelegateController', function(delegateFactory, $scope) {
  var loadInformation = function() {
    $scope.isLoading = true;
    delegateFactory.getManageDelegatesURL().then(function(data) {
      angular.extend($scope, data.data.feed.root);
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
