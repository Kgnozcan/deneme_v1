import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'lobby_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GameService _gameService = GameService();

  Future<void> _createRoom() async {
    if (_roomNameController.text.isEmpty || _nameController.text.isEmpty) return;

    String roomId = await _gameService.createRoom(
      _roomNameController.text,
      _nameController.text,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyScreen(
          roomId: roomId,
          playerId: _gameService.currentUserId,
          playerName: _nameController.text,
          isHost: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Oda Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _roomNameController,
              decoration: InputDecoration(labelText: 'Oda Adı'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'İsminiz'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createRoom,
              child: Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
