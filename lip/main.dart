import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hapi Clone',
      theme: ThemeData.dark(),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final roomController = TextEditingController();
  final userController = TextEditingController();

  Future<void> joinRoom() async {
    await [Permission.microphone, Permission.camera].request();
    
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => LiveRoomPage(
        roomID: roomController.text,
        userID: userController.text,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hapi + Bigo Live Room')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: userController, decoration: InputDecoration(labelText: 'Your Name')),
            SizedBox(height: 20),
            TextField(controller: roomController, decoration: InputDecoration(labelText: 'Room ID')),
            SizedBox(height: 40),
            ElevatedButton(onPressed: joinRoom, child: Text('Join Live Room'), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50))),
          ],
        ),
      ),
    );
  }
}

class LiveRoomPage extends StatelessWidget {
  final String roomID;
  final String userID;
  
  LiveRoomPage({required this.roomID, required this.userID});

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltLiveAudioRoom(
      appID: 123456789, // یہاں اپنا Zego AppID ڈالنا
      appSign: "your_app_sign", // یہاں اپنا AppSign ڈالنا
      userID: userID,
      userName: userID,
      roomID: roomID,
      config: ZegoUIKitPrebuiltLiveAudioRoomConfig.host(),
    );
  }
}
