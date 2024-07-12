import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_test/video.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveStartPage extends StatefulWidget {
  @override
  _LiveStartPageState createState() => _LiveStartPageState();
}

class _LiveStartPageState extends State<LiveStartPage> {
  final roomOptions = const RoomOptions(
    adaptiveStream: true,
    dynacast: true,
  );

  Participant<TrackPublication<Track>>? localParticipant;
  Participant<TrackPublication<Track>>? remoteParticipant;
  late Room roomstate;
  String token = '';
  final Uuid uuid = Uuid();
  String roomName = "";
  String errorMessage = '';
  bool isCameraOn = true;
  bool isMicOn = true;

  @override
  void initState() {
    super.initState();
    roomName = getFormattedCurrentDateTime();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }

    createRoomAndConnect();
  }

  String getFormattedCurrentDateTime() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('HHmmss');
    return formatter.format(now);
  }

  void createRoomAndConnect() async {
    try {
      final roomCreateResponse = await http.post(
        Uri.parse('https://livekit-test.colabmix.jp/api/room/create'),
        body: jsonEncode({'room_name': roomName}),
        headers: {"Content-Type": "application/json"},
      );

      if (roomCreateResponse.statusCode == 200) {
        final response = await http.post(
          Uri.parse('https://livekit-test.colabmix.jp/api/token/create'),
          body: jsonEncode({'room_name': roomName}),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          final tokenData = json.decode(response.body);
          token = tokenData['token'];
          connectToLivekit(roomName, token);
        } else {
          setState(() {
            errorMessage = 'Failed to retrieve token: ${response.body}';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to create room: ${roomCreateResponse.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to create room and connect: $e';
      });
    }
  }

  void connectToLivekit(String roomName, String token) async {
    const url = 'wss://livekit-test.colabmix.jp/livekit_server';
    final room = Room(roomOptions: roomOptions);
    roomstate = room;

    room.addListener(() {
      setState(() {
        localParticipant = room.localParticipant;
        remoteParticipant = room.remoteParticipants.isNotEmpty
            ? room.remoteParticipants.values.first
            : null;
      });
    });

    room.events.listen((event) {
      if (event is ParticipantConnectedEvent) {
        setState(() {
          remoteParticipant = event.participant;
        });
      } else if (event is TrackSubscribedEvent) {
        if (event.participant != localParticipant) {
          setState(() {
            remoteParticipant = event.participant;
          });
        }
      } else if (event is TrackUnsubscribedEvent) {
        if (event.participant != localParticipant) {
          setState(() {
            remoteParticipant = event.participant;
          });
        }
      }
    });

    try {
      await room.connect(url, token);
      setState(() {
        localParticipant = room.localParticipant!;
      });

      final cameraPublication = await room.localParticipant!.setCameraEnabled(true);
      final microphonePublication = await room.localParticipant!.setMicrophoneEnabled(true);

      if (cameraPublication == null && microphonePublication == null) {
        throw Exception('Failed to enable both camera and microphone');
      } else if (cameraPublication == null) {
        throw Exception('Failed to enable camera');
      } else if (microphonePublication == null) {
        throw Exception('Failed to enable microphone');
      }

    } catch (e) {
      setState(() {
        errorMessage = 'Connection failed: $e';
      });
    }
  }

  Future<void> toggleCamera() async {
    if (localParticipant != null) {
      isCameraOn = !isCameraOn;
      await roomstate.localParticipant!.setCameraEnabled(isCameraOn);
      setState(() {});
    }
  }

  Future<void> toggleMic() async {
    if (localParticipant != null) {
      isMicOn = !isMicOn;
      await roomstate.localParticipant!.setMicrophoneEnabled(isMicOn);
      setState(() {});
    }
  }

  @override
  void dispose() {
    roomstate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: $roomName'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: localParticipant != null
                    ? ParticipantWidget(localParticipant!)
                    : Container(
                      color: Colors.grey,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: remoteParticipant != null
                    ? ParticipantWidget(remoteParticipant!)
                    : Container(
                      color: Colors.grey,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 4.0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(isCameraOn ? Icons.videocam : Icons.videocam_off),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(isMicOn ? Icons.mic : Icons.mic_off),
              label: '',
            ),
          ],
          backgroundColor: Colors.white,
          onTap: (index) {
            if (index == 0) {
              toggleCamera();
            } else if (index == 1) {
              toggleMic();
            }
          },
        ),
      ),
    );
  }
}
