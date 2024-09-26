import 'package:flutter/material.dart';
import 'package:video_conference/validation.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoAudioCall extends StatefulWidget {
  final String callId;
  final String userId;

  const ZegoAudioCall({super.key, required this.callId, required this.userId});

  @override
  State<ZegoAudioCall> createState() => _ZegoAudioCallState();
}

class _ZegoAudioCallState extends State<ZegoAudioCall> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: APPID,
        appSign: APPSIGN,
        userID: widget.userId,
        userName: "User: ${widget.userId}",
        callID: widget.callId,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      ),
    );
  }
}
