import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_conference/validation.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoAudioCall extends StatefulWidget {
  final String callId;
  final String userId;
  final String calleeId; // The ID of the user receiving the call
  final String calleeName; // Optional: The name of the callee for display

  const ZegoAudioCall({
    super.key,
    required this.callId,
    required this.userId,
    required this.calleeId,
    this.calleeName = "",
  });

  @override
  State<ZegoAudioCall> createState() => _ZegoAudioCallState();
}

class _ZegoAudioCallState extends State<ZegoAudioCall> {
  @override
  void initState() {
    super.initState();
    _sendCallNotification();
  }

  // Function to send call notification to Firestore
  void _sendCallNotification() async {
    final callData = {
      "callerId": widget.userId,
      "callerName": "User: ${widget.userId}",
      "calleeId": widget.calleeId,
      "callId": widget.callId,
      "timestamp": FieldValue.serverTimestamp(),
      "callType": "voice",
      "isIncoming": true,
    };

    // Store call data in Firestore for the receiver to read
    await FirebaseFirestore.instance
        .collection("call_notifications")
        .add(callData);
  }

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

class IncomingCallPage extends StatefulWidget {
  final String userId;

  const IncomingCallPage({super.key, required this.userId});

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incoming Calls")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("call_notifications")
            .where("calleeId", isEqualTo: widget.userId)
            .where("isIncoming", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final calls = snapshot.data!.docs;

          return ListView.builder(
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              final callId = call['callId'];
              final callerName = call['callerName'];

              return ListTile(
                title: Text("Incoming Call from $callerName"),
                subtitle: Text("Call ID: $callId"),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    // Accept call by navigating to Zego call screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZegoUIKitPrebuiltCall(
                          appID: APPID,
                          appSign: APPSIGN,
                          userID: widget.userId,
                          userName: "User: ${widget.userId}",
                          callID: callId,
                          config:
                              ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
                        ),
                      ),
                    );
                    // Mark call as not incoming to avoid multiple acceptances
                    FirebaseFirestore.instance
                        .collection("call_notifications")
                        .doc(call.id)
                        .update({"isIncoming": false});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
