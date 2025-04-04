import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../services/game_service.dart';
import 'game_screen.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String playerName;
  final bool isHost;

  const LobbyScreen({
    Key? key,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.isHost,
  }) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final GameService _gameService = GameService();
  late Stream<Room> _roomStream;
  bool _startingGame = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _roomStream = _gameService.getRoomStream(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lobi')),
      body: StreamBuilder<Room>(
        stream: _roomStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Oda bulunamadı.'));
          }

          final room = snapshot.data!;

          if (room.isGameStarted && !_navigated) {
            _navigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    roomId: room.id,
                    playerId: widget.playerId,
                    playerName: widget.playerName,
                    isHost: widget.isHost,
                  ),
                ),
              );
            });
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text('Oda Kodu: ${room.id}', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 20),
              Text('Oyuncular:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              ...room.players.map((player) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  player.name,
                  style: TextStyle(fontSize: 16),
                ),
              )),
              const SizedBox(height: 30),
              if (widget.isHost && !_startingGame)
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _startingGame = true;
                    });
                    await _gameService.startGame(widget.roomId);
                  },
                  child: Text('Oyunu Başlat'),
                ),
              if (!widget.isHost)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text('Ev sahibinin oyunu başlatması bekleniyor...'),
                ),
              if (_startingGame)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text('Oyun başlatılıyor...'),
                ),
            ],
          );
        },
      ),
    );
  }
}