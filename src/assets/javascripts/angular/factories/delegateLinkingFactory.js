'use strict';

var angular = require('angular');

/**
 * POST to the Campus Solutions API which links delegate to a student account
 */
angular.module('calcentral.factories').factory('delegateLinkingFactory', function(apiService, $http) {
  var urlDelegateAccessAPI = '/api/campus_solutions/delegate_access';

  var getTermsAndConditions = function(options) {
    return apiService.http.request(options, urlDelegateAccessAPI);
  };
  var postSecurityKey = function(options) {
    return $http.post(urlDelegateAccessAPI, options);
  };

  return {
    getTermsAndConditions: getTermsAndConditions,
    postSecurityKey: postSecurityKey
  };
});
