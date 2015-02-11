var config = require('./config.js');
Built.initialize('blte1163927e03db5d1', 'studywithme');

Built.Extension.beforeSave('study_group', function(request, response) {

  var creator_uid = request.object.get('app_user_object_uid');
  var courseName = request.object.get('course');
  var location = request.object.get('location');
  var start_time = request.object.get('start_time');
  var end_time = request.object.get('end_time');

  Built.User.login(
    config.notification_user_email(),
    config.notification_user_password(),
    { 
      onSuccess: function(data, res) {
        // you have successfully logged in
        // data.application_user will contain the profile
        Built.setHeaders('authtoken', data.application_user.authtoken);
        var course_query = new Built.Query('course');
        course_query.where('name', courseName);
        course_query.setMasterKey(config.masterKey());
        course_query.only(['uid', 'app_user_object_uid']);

        course_query.exec({
          onSuccess: function(data) {
            console.log('course query done');
            console.log(data);
            var user_uids = [];

            for (i = 0; i < data.length; i++) {
              console.log(data[i]);
              user_uids.push(data[i].get('app_user_object_uid'));
            }

            // Don't send notification to the person who made study group
            var index = user_uids.indexOf(creator_uid);
            if (index > -1) {
              user_uids.splice(index, 1);
            }
            console.log(user_uids);

            var notification = new Built.Notification();
            notification.addUsers(user_uids);

            var message = "There is a new study group for " + courseName + " from " + start_time + " to " + end_time + " at " + location + "!"
            notification.setMessage(message);
            console.log('about to send');
            console.log(message);
            notification.send({
              onSuccess: function(data) {
                console.log("Notification - Success");
                console.log(data);
              },
              onError: function(err) {
                console.log("Notification - ERROR");
                console.log(err);
              }
            });
          },
          onError: function(err) {
            console.log("ERROR");
            console.log(err);
          }
        });
      }
    }
  );
  return response.success();
});

Built.Extension.beforeSave('message', function(request, response) {
  console.log(request);
  var creator_uid = request.object.get('app_user_object_uid');
  var sender_display_name = request.object.get('sender_display_name');
  var sender_id = request.object.get('sender_id');
  var study_group_uid = request.object.get('study_group');
  var original_message = request.object.get('message');

  Built.User.login(
    config.notification_user_email(),
    config.notification_user_password(),
    { 
      onSuccess: function(data, res) {
        // you have successfully logged in
        // data.application_user will contain the profile
        Built.setHeaders('authtoken', data.application_user.authtoken);

        var myQuery = new Built.Query('study_group');
 
        myQuery.where('uid', study_group_uid);
        myQuery.only(['uid', 'app_user_object_uid', 'course']);
        myQuery.exec({
          onSuccess: function(data) {
            var study_group = data[0];
            var study_group_course = study_group.get('course');
            var study_group_creator = study_group.get('app_user_object_uid');

            var message_query = new Built.Query('message');
            message_query.where('study_group', study_group_uid);
            message_query.setMasterKey(config.masterKey());
            message_query.only(['uid', 'app_user_object_uid']);

            message_query.exec({
              onSuccess: function(data) {
                console.log('message query done');
                var user_uids = [];

                for (i = 0; i < data.length; i++) {
                  console.log(data[i]);
                  user_uids.push(data[i].get('app_user_object_uid'));
                }

                // The study group creator is included by default
                user_uids.push(study_group_creator);

                // get unique user ids.

                function unique(arr) {
                  var hash = {}, result = [];
                  for ( var i = 0, l = arr.length; i < l; ++i ) {
                    if ( !hash.hasOwnProperty(arr[i]) ) {
                      hash[ arr[i] ] = true;
                      result.push(arr[i]);
                    }
                  }
                  return result;
                }

                console.log(user_uids);
                user_uids = unique(user_uids);
                console.log(user_uids);

                // Don't send notification to the person who made study group
                var index = user_uids.indexOf(creator_uid);
                if (index > -1) {
                  user_uids.splice(index, 1);
                }
                console.log(user_uids);

                var notification = new Built.Notification();
                notification.addUsers(user_uids);

                var message = sender_display_name + ": " + original_message + " - in " + study_group_course;
                notification.setMessage(message);
                console.log(message);
                notification.send({
                  onSuccess: function(data) {
                    console.log("Notification - Success");
                    console.log(data);
                  },
                  onError: function(err) {
                    console.log("Notification - ERROR");
                    console.log(err);
                  }
                });
              },
              onError: function(err) {
                console.log("ERROR");
                console.log(err);
              }
            });
          },
          onError: function(err) {
            console.log("ERROR");
            console.log(err);
          }
        });
      }
    }
  );
  return response.success();
});
