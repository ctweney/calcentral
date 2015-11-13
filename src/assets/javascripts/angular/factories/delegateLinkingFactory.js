'use strict';

var angular = require('angular');

/**
 * POST to the Campus Solutions API which links delegate to a student account
 */
angular.module('calcentral.factories').factory('delegateLinkingFactory', function($http) {
  var urlDelegateAccessAPI = '/api/campus_solutions/delegate_access';

  var getTermsAndConditions = function() {
    return $http.get(urlDelegateAccessAPI);
  };
  var postSecurityKey = function(options) {
    return $http.post(urlDelegateAccessAPI, options);
  };

  return {
    getTermsAndConditions: getTermsAndConditions,
    postSecurityKey: postSecurityKey
  };
});
