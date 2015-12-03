'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Language section controller
 */
angular.module('calcentral.controllers').controller('LanguagesSectionController', function(profileFactory, $scope, $q) {
  var levelMapping = {
    native: 'native',
    teach: 'teacher',
    translate: 'translator'
  };

  var parseLevels = function(languages) {
    languages = _.map(languages, function(language) {
      if (!language.levels) {
        language.levels = [];
      }
      _.each(levelMapping, function(value, key) {
        if (language[key]) {
          language.levels.push(value);
        }
      });
      return language;
    });
    return languages;
  };

  var parsePerson = function(data) {
    var person = data.data.feed.student;
    var languages = parseLevels(person.languages);
    angular.extend($scope, {
      languages: {
        content: languages
      }
    });
  };

  var getPerson = profileFactory.getPerson().then(parsePerson);

  var loadInformation = function() {
    $q.all(getPerson).then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
