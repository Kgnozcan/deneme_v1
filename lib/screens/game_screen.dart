import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  final String roomId;

  const GameScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Oyun Ekranı')),
      body: Center(
        child: Text('Oyun başladı! Oda ID: $roomId'),
      ),
    );
  }
}
