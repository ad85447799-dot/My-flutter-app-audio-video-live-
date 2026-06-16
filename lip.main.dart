import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LivePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LivePage extends StatefulWidget {
  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.camera, Permission.microphone].request();
    
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: 'تمہارا_AGORA_APP_ID_یہاں_لگاؤ',
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (conn, elapsed) {
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (conn, uid, elapsed) {
          setState(() => _remoteUid = uid);
        },
        onUserOffline: (conn, uid, reason) {
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: null,
      channelId: 'live_room',
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Room - Audio + Video')),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 120, height: 160,
              child: _localVideo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _localVideo() {
    if (!_localUserJoined) return Text('Camera ON...');
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid == null) return Text('Waiting for other user...');
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _remoteUid!),
        connection: RtcConnection(channelId: 'live_room'),
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}
