import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import 'jitsi_meet_wrapper_stub.dart'
if (dart.library.io) 'jitsi_meet_wrapper_mobile.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomName;
  final String userName;

  const VideoCallScreen({required this.roomName, required this.userName});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  void initState() {
    super.initState();
    joinMeeting(roomName: widget.roomName, userName: widget.userName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Call"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text(
          "Connecting to video call...\nRoom: ${widget.roomName}",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
