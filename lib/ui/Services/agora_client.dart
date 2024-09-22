/*
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

class AgoraClientVideo extends StatefulWidget {
  const AgoraClientVideo({super.key});

  @override
  State<AgoraClientVideo> createState() => _AgoraClientVideoState();
}

class _AgoraClientVideoState extends State<AgoraClientVideo> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "0470f57647474e4895b712275814acd9",
      channelName: "test",
      username: "user",
    ),
  );

  bool _isInitialized = false;
  String _statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    try {
      await client.initialize();
      setState(() {
        _isInitialized = true;
        _statusMessage = "Connected";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Initialization failed: $e";
      });
    }
  }

  @override
  void dispose() {
    client.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Call'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await client.engine.leaveChannel();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: _isInitialized
              ? Stack(
                  children: [
                    AgoraVideoViewer(
                      client: client,
                      layoutType: Layout.floating,
                      enableHostControls: true, // Enable host controls
                    ),
                    AgoraVideoButtons(
                      client: client,
                      addScreenSharing: false, // Disable screen sharing
                    ),
                  ],
                )
              : Center(
                  child: Text(_statusMessage),
                ),
        ),
      ),
    );
  }
}
*/
