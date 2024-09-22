/*
import 'package:flutter/material.dart';
import 'package:video_conference/validation.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoVideoCall extends StatefulWidget {
  final String callId;
  final String userId;

  const ZegoVideoCall({super.key, required this.callId, required this.userId});

  @override
  State<ZegoVideoCall> createState() => _ZegoVideoCallState();
}

class _ZegoVideoCallState extends State<ZegoVideoCall> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: APPID,
        appSign: APPSIGN,
        userID: widget.userId,
        userName: "User: ${widget.userId}",
        callID: widget.callId,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}
*/
