'use strict';

var angular = require('angular');

angular.module('calcentral.services').service('delegateService', function($q) {
  /**
   * Fired after an action (e.g., save) has finished
   */
  var actionCompleted = function(data) {
    if (data.errorMessage) {
      $q.reject(data.errorMessage);
    } else {
      $q.resolve({
        refresh: true
      });
    }
  };

  /**
   * Save a certain item in a section
   */
  var save = function($scope, action, item) {
    $scope.errorMessage = '';
    $scope.isSaving = true;
    return action(item);
  };

  // Expose methods
  return {
    actionCompleted: actionCompleted,
    save: save
  };
});
