'use strict';

/**
 * @ngdoc function
 * @name websiteApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the websiteApp
 */
angular.module('websiteApp')
  .controller('MainCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

    $scope.features = [
    	{
    		'title': 'Study Groups',
    		'description': 'Get notified of study groups happening nearby for your classes'
    	},
    	{
    		'title': 'Messaging',
    		'description': 'Send messages to your new found study partners so you know exactly who you are finding'
    	},
    	{
    		'title': 'Get motivated',
    		'description': 'Get motivated to complete more challenges by seeing your current and highest streak as well as how many challenges you have completed!'
    	}
    ];

    $scope.submit = function(email) {
      if (email === undefined) {
        return;
      }
      /*global Built */
      
      Built.init('blt2edd3e168f0a895a','anappleaday');
      Built.Extension.execute('invite', {email: email}, {
        onSuccess: function(data) {
          // executed successfully
          console.log(data.result);
        },
        onError: function() {
          // error
          console.log('fail');
        }
      });
    };
  });
