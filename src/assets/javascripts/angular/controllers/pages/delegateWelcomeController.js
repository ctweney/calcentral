'use strict';

var angular = require('angular');

/**
 * Welcome newly assigned delegates
 */
angular.module('calcentral.controllers').controller('DelegateWelcomeController', function(apiService) {
  apiService.util.setTitle('Welcome');
});
