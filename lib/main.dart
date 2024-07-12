import 'package:flutter/material.dart';
import 'package:livekit_test/top.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await _checkPermissions();
  // await _initializeAndroidAudioSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TopPage(title: 'LiveKit Demo'),
    );
  }
}

// Future<void> _checkPermissions() async {
//   var status = await Permission.bluetooth.request();
//   if (status.isPermanentlyDenied) {
//     print('Bluetooth Permission disabled');
//   }
//   status = await Permission.bluetoothConnect.request();
//   if (status.isPermanentlyDenied) {
//     print('Bluetooth Connect Permission disabled');
//   }
// }
// Future<void> _initializeAndroidAudioSettings() async {
//   await webrtc.WebRTC.initialize(options: {
//     'androidAudioConfiguration': webrtc.AndroidAudioConfiguration.media.toMap()
//   });
//   webrtc.Helper.setAndroidAudioConfiguration(
//       webrtc.AndroidAudioConfiguration.media);
// }
