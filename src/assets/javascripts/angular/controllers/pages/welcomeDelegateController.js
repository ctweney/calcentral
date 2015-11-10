'use strict';

var angular = require('angular');

/**
 * Controller welcomes newly assigned delegate users
 */
angular.module('calcentral.controllers').controller('WelcomeDelegateController', function(apiService) {
  apiService.util.setTitle('Welcome');
});
