'use strict';

var angular = require('angular');

angular.module('calcentral.services').service('delegateService', function() {
  /**
   * Fired after an action (e.g., save) has finished
   */
  var actionCompleted = function($scope, data, callback) {
    if (data.data.errored) {
      $scope.errorMessage = data.data.feed.errmsgtext;
    } else {
      callback({
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
