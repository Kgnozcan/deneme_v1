class Player {
  final String id;
  final String name;
  final bool isHost;
  int score;

  Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.score = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isHost': isHost,
      'score': score,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      isHost: map['isHost'] ?? false,
      score: map['score'] ?? 0,
    );
  }
}
