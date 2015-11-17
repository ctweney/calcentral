'use strict';

var angular = require('angular');

/**
 * POST to the Campus Solutions API which links delegate to a student account
 */
angular.module('calcentral.factories').factory('delegateFactory', function(apiService, $http) {
  var urlDelegateAccess = '/api/campus_solutions/delegate_access';

  var getTermsAndConditions = function(options) {
    return apiService.http.request(options, urlDelegateAccess);
  };
  var linkAccounts = function(options) {
    return $http.post(urlDelegateAccess, options);
  };

  return {
    getTermsAndConditions: getTermsAndConditions,
    linkAccounts: linkAccounts
  };
});
