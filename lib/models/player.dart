class Player {
  final String id;
  final String name;
  final bool isHost; // Eksik parametre eklendi

  Player({required this.id, required this.name, this.isHost = false}); // Varsayılan olarak false
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'isHost': isHost};
  factory Player.fromMap(Map<String, dynamic> map) =>
      Player(id: map['id'], name: map['name'], isHost: map['isHost'] ?? false);
}
