import 'player.dart';

class Room {
  final String id;
  final String name;
  final List<Player> players;
  final bool isGameStarted;
  final int maxRounds;

  Room({
    required this.id,
    required this.name,
    required this.players,
    this.isGameStarted = false,
    this.maxRounds = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'players': players.map((p) => p.toMap()).toList(),
      'isGameStarted': isGameStarted,
      'maxRounds': maxRounds,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      players: List<Player>.from(map['players']?.map((p) => Player.fromMap(p)) ?? []),
      isGameStarted: map['isGameStarted'] ?? false,
      maxRounds: map['maxRounds'] ?? 5,
    );
  }
}
