'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Controller for users wanting to manage delegates
 */
angular.module('calcentral.controllers').controller('DelegateController', function(delegateFactory, $scope) {
  $scope.delegate = {
    isLoading: true
  };

  var loadInformation = function() {
    delegateFactory.getManageDelegatesURL().then(function(data) {
      angular.extend($scope, _.get(data, 'data.feed.root'));
      $scope.delegate.isLoading = false;
    });
  };

  loadInformation();
});
