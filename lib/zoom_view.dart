import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_zoom_plugin/zoom_options.dart';

typedef void ZoomViewCreatedCallback(ZoomViewController controller);

class ZoomView extends StatefulWidget {
  const ZoomView({
    Key key,
    this.zoomOptions,
    this.meetingOptions,
    this.onViewCreated,
  }) : super(key: key);

  final ZoomViewCreatedCallback onViewCreated;
  final ZoomOptions zoomOptions;
  final ZoomMeetingOptions meetingOptions;

  @override
  State<StatefulWidget> createState() => _ZoomViewState();
}

class _ZoomViewState extends State<ZoomView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'flutter_zoom_plugin',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'flutter_zoom_plugin',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the flutter_zoom_plugin plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onViewCreated == null) {
      return;
    }

    var controller = new ZoomViewController._(id);
    widget.onViewCreated(controller);
  }
}

class ZoomViewController {

  ZoomViewController._(int id) :
        _methodChannel = new MethodChannel('com.decodedhealth/flutter_zoom_plugin'),
        _zoomStatusEventChannel = new EventChannel("com.decodedhealth/zoom_event_stream");

  final MethodChannel _methodChannel;
  final EventChannel _zoomStatusEventChannel;

  Future<List> initZoom(ZoomOptions options) async {
    assert(options != null);

    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("appKey", () => "M4XqWxJbT6ablN0EgLjcVQ");
    optionMap.putIfAbsent("appSecret", () => "IuFzBXvljzhu8ym6Dn0LnQCKFSKRuHmc499R");
    optionMap.putIfAbsent("domain", () => "zoom.us");

    return _methodChannel.invokeMethod('init', optionMap);
  }

  Future<bool> joinMeeting(ZoomMeetingOptions options) async {
    assert(options != null);
    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("userId", () => 'ray@ncrtechnosolutions.com');
    optionMap.putIfAbsent("meetingId", () => "96629020747");
    optionMap.putIfAbsent("meetingPassword", () =>"123456");
    optionMap.putIfAbsent("disableDialIn", () => "true");
    optionMap.putIfAbsent("disableDrive", () => "true");
    optionMap.putIfAbsent("disableInvite", () => "true");
    optionMap.putIfAbsent("disableShare", () => "true");
    optionMap.putIfAbsent("noDisconnectAudio", () => "false");
    optionMap.putIfAbsent("noAudio", () => "false");

    return _methodChannel.invokeMethod('join', optionMap);
  }


  Future<List> meetingStatus(String meetingId) async {
    assert(meetingId != null);

    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("meetingId", () => meetingId);

    return _methodChannel.invokeMethod('meeting_status', optionMap);
  }

  Stream<dynamic> get zoomStatusEvents {
    return _zoomStatusEventChannel.receiveBroadcastStream();
  }

}
