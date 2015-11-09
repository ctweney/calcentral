'use strict';

var angular = require('angular');

/**
 * Work Experience controller
 */
angular.module('calcentral.controllers').controller('WorkExperienceController', function(profileFactory, $scope) {
  var loadInformation = function() {
    profileFactory.getWorkExperience().then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
