import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_test/join.dart';
import 'package:livekit_test/video.dart';
import 'package:permission_handler/permission_handler.dart';


class RoomListPage extends StatefulWidget {
  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  bool isLoading = true;
  List<String> rooms = [];
  String selectedRoom = '';
  String token = '';
  late Room room;
  Participant? localParticipant;
  Participant? remoteParticipant;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRoomList();
  }

  Future<void> fetchRoomList() async {
    try {
      final response = await http.get(Uri.parse('https://livekit-test.colabmix.jp/api/room/list'));
      if (response.statusCode == 200) {
        setState(() {
          rooms = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTokenAndJoinRoom(String roomName) async {
    try {
      final response = await http.post(
        Uri.parse('https://livekit-test.colabmix.jp/api/token/create'),
        body: jsonEncode({'room_name': roomName}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final tokenData = json.decode(response.body);
        token = tokenData['token'];

        Navigator.push(context, MaterialPageRoute(builder: (context) => JoinPage(roomName: roomName, token: token)));
      } else {
        print('Failed to load token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> connectToLiveKit(String roomName, String token) async {
    await requestPermissions();

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
      await room.connect('wss://livekit-test.colabmix.jp/livekit_server', token);
      await room.localParticipant!.setCameraEnabled(true);
      await room.localParticipant!.setMicrophoneEnabled(true);
    } catch (e) {
      setState(() {
        errorMessage = 'Connection failed: $e';
      });
      print(errorMessage);
    }
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Room'),
      ),
      body: Center(
        child: Column(
          children: [
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(rooms[index]),
                      onTap: () async {
                        await requestPermissions();
                        fetchTokenAndJoinRoom(rooms[index]);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}