/*
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const String APP_ID = "0470f57647474e4895b712275814acd9";
const String CHANNEL_NAME = "test_channel";
const String TEMP_TOKEN =
    "007eJxTYHAROOa1922F62qHdRdcpiek7d198cf/6ueXl9cs+zpNQn2dAoOBiblBmqm5mYk5EKaaWFiaJpkbGhmZm1oYmiQmp1hOs76d1hDIyNBiIMLEyACBID4PQ0lqcUl8ckZiXl5qDgMDAAcHJAg="; // You can generate this token from Agora console.

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _isJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Request permissions for camera and microphone
    await [Permission.camera, Permission.microphone].request();

    // Create an instance of the Agora engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: APP_ID));

    // Set event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user ${connection.localUid} joined");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Enable video
    await _engine.enableVideo();

    // Join the channel
    await _engine.joinChannel(
      token: TEMP_TOKEN,
      channelId: CHANNEL_NAME,
      uid: 0, // 0 means Agora will assign an ID automatically
      options: const ChannelMediaOptions(),
    );
  }

  // Create a local video view
  Widget _renderLocalPreview() {
    if (_isJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Center(
          child: Text('Joining channel, please wait...',
              textAlign: TextAlign.center));
    }
  }

  // Create a remote video view
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: CHANNEL_NAME),
        ),
      );
    } else {
      return const Center(
          child: Text('Waiting for remote user to join',
              textAlign: TextAlign.center));
    }
  }

  @override
  void dispose() {
    // Leave channel and destroy the Agora engine when disposed
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: Stack(
        children: [
          Center(child: _renderRemoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 120,
              height: 160,
              child: _renderLocalPreview(),
            ),
          ),
        ],
      ),
    );
  }
}
*/
