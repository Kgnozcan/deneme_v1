import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/room.dart';
import '../models/player.dart';
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
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final GameService _gameService = GameService();
  late Stream<Room> _roomStream;
  bool _startingGame = false;

  @override
  void initState() {
    super.initState();
    _roomStream = _gameService.getRoomStream(widget.roomId);

    // 🧪 TEST MODU: Eğer ev sahibiysen oyunu otomatik başlat
    Future.delayed(Duration(seconds: 2), () async {
      if (widget.isHost) {
        await _gameService.startGame(widget.roomId);
      }
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _startingGame = true;
    });

    try {
      await _gameService.startGame(widget.roomId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oyun başlatılırken hata oluştu: $e')),
      );
      setState(() {
        _startingGame = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Oyun Lobisi')),
      body: StreamBuilder<Room>(
        stream: _roomStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final room = snapshot.data!;

          if (room.isGameStarted) {
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

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Oda Kodu: ${room.id}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Oyuncular:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: room.players.length,
                    itemBuilder: (context, index) {
                      final player = room.players[index];
                      return ListTile(
                        title: Text(player.name),
                        trailing: player.isHost
                            ? Chip(label: Text('Ev Sahibi'))
                            : null,
                      );
                    },
                  ),
                ),
                if (widget.isHost)
                  ElevatedButton(
                    onPressed:
                    room.players.length >= 2 && !_startingGame ? _startGame : null,
                    child: _startingGame
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Oyunu Başlat'),
                  )
                else
                  Text(
                    'Ev sahibinin oyunu başlatmasını bekleyin...',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
