'use strict';

var angular = require('angular');

/**
 * Controller for page containing view-as widget and other admin-related tools
 */
angular.module('calcentral.controllers').controller('MyToolboxController', function(apiService) {
  apiService.util.setTitle('My Toolbox');
});
