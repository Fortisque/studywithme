var config = require('./config.js');
Built.initialize('blte1163927e03db5d1', 'studywithme');

Built.Extension.define('invite', function(request, response) {
  var invitees = Built.Object.extend('invitees');
  var invitee = new invitees();
  invitee.set({
    email: request.params.email
  });
  invitee.save({
    onSuccess: function(data, res) {
      // object creation is successful
      return response.success(request.params.email);
    },
    onError: function(err) {
      // some error has occurred
      // refer to the "error" object for more details
      console.log(err);
    }
  });
});

Built.Extension.beforeSave('study_group', function(request, response) {
  console.log(request);

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
            var user_uids = [];

            for (i = 0; i < data.length; i++) { 
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

            notification.setMessage("New study group for " + courseName + " at " + location + " from " + start_time + " to " + end_time + ".");
            console.log('about to send');
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
