import 'package:flutter/material.dart';
import 'package:livekit_test/live_start.dart';

import 'room_list.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key, required this.title});
  final String title;

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text(
          'LiveKit テスト',
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors),
              label: 'ライブを始める',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'ライブに参加',
            ),
          ],
          backgroundColor: Colors.white,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LiveStartPage()));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RoomListPage()));
            }
          },
        ),
      ),
    );
  }
}
