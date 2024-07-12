import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_test/video.dart';

class JoinPage extends StatefulWidget {
  final String roomName;
  final String token;

  JoinPage({required this.roomName, required this.token});

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  late Room room;
  Participant? localParticipant;
  Participant? remoteParticipant;
  bool isCameraOn = true;
  bool isMicOn = true;

  @override
  void initState() {
    super.initState();
    connectToRoom();
  }

  Future<void> connectToRoom() async {
    const roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
    );

    room = Room(roomOptions: roomOptions);

    room.addListener(() {
      setState(() {
        localParticipant = room.localParticipant;
        if (room.remoteParticipants.isNotEmpty) {
          remoteParticipant = room.remoteParticipants.values.first;
        }
      });
    });

    try {
      await room.connect('wss://livekit-test.colabmix.jp/livekit_server', widget.token);
      await room.localParticipant!.setCameraEnabled(true);
      await room.localParticipant!.setMicrophoneEnabled(true);
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  Future<void> toggleCamera() async {
    if (localParticipant != null) {
      isCameraOn = !isCameraOn;
      await room.localParticipant!.setCameraEnabled(isCameraOn);
      setState(() {});
    }
  }

  Future<void> toggleMic() async {
    if (localParticipant != null) {
      isMicOn = !isMicOn;
      await room.localParticipant!.setMicrophoneEnabled(isMicOn);
      setState(() {});
    }
  }

  @override
  void dispose() {
    room.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.roomName}'),
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


