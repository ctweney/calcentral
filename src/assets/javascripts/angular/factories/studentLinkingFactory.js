'use strict';

var angular = require('angular');

/**
 * POST to the Campus Solutions API which links delegate to a student account
 */
angular.module('calcentral.factories').factory('studentLinkingFactory', function($http) {
  var getTermsAndConditions = function() {
    return $http.get('/api/delegated_access/terms_and_conditions');
  };

  return {
    getTermsAndConditions: getTermsAndConditions
  };
});
