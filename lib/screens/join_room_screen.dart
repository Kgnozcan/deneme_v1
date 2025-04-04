import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lobby_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _playerNameController = TextEditingController();
  String? _error;

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim();
    final playerName = _playerNameController.text.trim();

    if (roomCode.isEmpty || playerName.isEmpty) {
      setState(() {
        _error = 'Lütfen tüm alanları doldurun.';
      });
      return;
    }

    final roomDoc = FirebaseFirestore.instance.collection('rooms').doc(roomCode);
    final docSnapshot = await roomDoc.get();

    if (!docSnapshot.exists) {
      setState(() {
        _error = 'Böyle bir oda bulunamadı.';
      });
      return;
    }

    final newPlayer = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': playerName,
      'score': 0,
      'isHost': false,
    };

    await roomDoc.update({
      'players': FieldValue.arrayUnion([newPlayer])
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LobbyScreen(
            roomId: roomCode,
            playerId: newPlayer['id'] as String,
            isHost: false,
            playerName: playerName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Odaya Katıl')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _roomCodeController,
              decoration: const InputDecoration(labelText: 'Oda Kodu'),
            ),
            TextField(
              controller: _playerNameController,
              decoration: const InputDecoration(labelText: 'Oyuncu İsmi'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinRoom,
              child: const Text('Katıl'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
