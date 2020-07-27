import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_plugin/zoom_options.dart';
import 'package:flutter_zoom_plugin/zoom_view.dart';
import 'package:zoom_vdocll_app/join_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [ ],
      initialRoute: '/',
      routes: {
        '/': (context) => JoinWidget(),
        '/meeting': (context) => MeetingWidget(),
      },
//      home: MeetingWidget(),
    );
  }
}

class MeetingWidget extends StatelessWidget  {
  ZoomOptions zoomOptions;
  ZoomMeetingOptions meetingOptions;

  MeetingWidget({Key key, meetingId, meetingPassword}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "M4XqWxJbT6ablN0EgLjcVQ",
      appSecret: "IuFzBXvljzhu8ym6Dn0LnQCKFSKRuHmc499R",
    );
    this.meetingOptions = new ZoomMeetingOptions(
        userId: 'ray@ncrtechnosolutions.com',
        meetingId: meetingId,
        meetingPassword: meetingPassword,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        noAudio: "false",
        noDisconnectAudio: "false"
    );
  }
//  ZoomOptions zoomOptions = new ZoomOptions(
//    domain: "zoom.us",
//    appKey: "M4XqWxJbT6ablN0EgLjcVQ",
//    // Replace with with key got from the Zoom Marketplace
//    appSecret:
//        "IuFzBXvljzhu8ym6Dn0LnQCKFSKRuHmc499R", // Replace with with secret got from the Zoom Marketplace
//  );

//  ZoomMeetingOptions meetingOptions = new ZoomMeetingOptions(
//      userId: 'ray@ncrtechnosolutions.com',
//      meetingId: "93283182276",
//      meetingPassword: "447180",
//      disableDialIn: "true",
//      disableDrive: "true",
//      disableInvite: "true",
//      disableShare: "true",
//      noAudio: "false",
//      noDisconnectAudio: "false");

  Timer timer;

  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid)
      result = status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    else
      result = status == "MEETING_STATUS_IDLE";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading meeting '),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ZoomView(onViewCreated: (controller) {
          print("Created the view");

          controller.initZoom(this.zoomOptions).then((results) {
            print("initialised");
            print(results);

            if (results[0] == 0) {
              // Listening on the Zoom status stream (1)
              controller.zoomStatusEvents.listen((status) {
                print(
                    "Meeting Status Stream: " + status[0] + " - " + status[1]);

                if (_isMeetingEnded(status[0])) {
                  Navigator.pop(context);
                  timer?.cancel();
                }
              });

              print("listen on event channel");

              controller
                  .joinMeeting(this.meetingOptions)
                  .then((joinMeetingResult) {
                // Polling the Zoom status (2)
                timer = Timer.periodic(new Duration(seconds: 2), (timer) {
                  controller
                      .meetingStatus(this.meetingOptions.meetingId)
                      .then((status) {
                    print("Meeting Status Polling: " +
                        status[0] +
                        " - " +
                        status[1]);
                  });
                });
              });
            }
          }).catchError((error) {
            print(error);
          });
        }),
      ),
    );
  }
}

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Zoom Video call"),
//      ),
//      body: Center(
//
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              'You have pushed the button this many times:',
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: Center(
//        child: FloatingActionButton(
//          onPressed: (){},
//          tooltip: 'VDO call',
//          child: Icon(Icons.missed_video_call),
//        ),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
