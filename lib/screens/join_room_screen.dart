import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'lobby_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GameService _gameService = GameService();

  Future<void> _joinRoom() async {
    if (_roomCodeController.text.isEmpty || _nameController.text.isEmpty) return;

    bool success = await _gameService.joinRoom(
      _roomCodeController.text,
      _nameController.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LobbyScreen(
            roomId: _roomCodeController.text,
            playerId: _gameService.currentUserId,
            playerName: _nameController.text,
            isHost: false, // Eklendi!
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Odaya katılamadınız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Odaya Katıl')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _roomCodeController,
              decoration: InputDecoration(labelText: 'Oda Kodu'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'İsminiz'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinRoom,
              child: Text('Katıl'),
            ),
          ],
        ),
      ),
    );
  }
}
