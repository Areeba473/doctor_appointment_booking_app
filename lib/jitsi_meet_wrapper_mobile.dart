import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

Future<void> joinMeeting({
  required String roomName,
  required String userName,
}) async {
  try {
    var options = JitsiMeetingOptions(
      roomNameOrUrl: roomName,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
      },
      userDisplayName: userName,
    );

    await JitsiMeetWrapper.joinMeeting(
      options: options,
      listener: JitsiMeetingListener(
        onConferenceWillJoin: (String message) {
          print("Will join: $message");
        },
        onConferenceJoined: (String message) {
          print("Joined: $message");
        },
        onConferenceTerminated: (String message, Object? error) {
          print("Terminated: $message");
        },
      ),
    );
  } catch (e) {
    print("Error joining meeting: $e");
  }
}
