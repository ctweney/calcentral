'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Work Exprience Section controller
 */
angular.module('calcentral.controllers').controller('WorkExperienceSectionController', function(apiService, profileFactory, $scope) {
  var initialState = {
    items: {
      content: []
    }
  };

  angular.extend($scope, initialState);

  /**
   * Format a specific date to the MM/DD/YYYY format
   */
  var formatDate = function(date) {
    return apiService.date.moment(date, 'YYYY-MM-DD').format('L');
  };

  /**
   * Format the dates in the work exprience API
   */
  var formatDates = function(data) {
    if (!data) {
      return;
    }
    var toFormatDates = ['payFrequency.fromDate', 'payFrequency.toDate'];

    _.map(data, function(dataElement) {
      _.each(toFormatDates, function(toFormatDate) {
        var date = _.get(dataElement, toFormatDate);
        if (date) {
          _.set(dataElement, toFormatDate, formatDate(date));
        }
      });
      return dataElement;
    });

    return data;
  };

  var parseWorkExperience = function(data) {
    var parsedData = formatDates(_.get(data, 'data.feed.workExperiences'));
    angular.extend($scope, {
      items: {
        content: parsedData
      }
    });
  };

  var getWorkExperience = profileFactory.getWorkExperience;

  var loadInformation = function(options) {
    $scope.isLoading = true;

    getWorkExperience({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parseWorkExperience)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
