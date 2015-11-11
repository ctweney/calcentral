'use strict';

var angular = require('angular');

/**
 * POST to the Campus Solutions API which links delegate to a student account
 */
angular.module('calcentral.factories').factory('studentLinkingFactory', function(apiService, $http) {
  // TODO: var urlTermsAndConditions = 'TBD';
  var urlPostSecurityKey = 'TBD';

  // Get text
  var getTermsAndConditions = function() {
    // TODO: return apiService.http.request(options, urlTermsAndConditions);
    return 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
  };

  // Post
  var linkAccounts = function(options) {
    return $http.post(urlPostSecurityKey, options);
  };

  return {
    termsAndConditions: getTermsAndConditions,
    linkAccounts: linkAccounts
  };
});
