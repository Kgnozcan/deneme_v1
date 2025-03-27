import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';
import '../models/player.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının Firebase kimliğini al
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // 📌 **4 Haneli Oda Kodu Üreten Fonksiyon**
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
        List.generate(4, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  // Yeni bir oda oluştur
  Future<String> createRoom(String roomName, String hostName) async {
    final String roomId = _generateRoomCode(); // **Oda kodu artık 4 karakter**

    Player host = Player(id: currentUserId, name: hostName, isHost: true);
    Room newRoom = Room(id: roomId, name: roomName, players: [host]);

    await _firestore.collection('rooms').doc(roomId).set(newRoom.toMap());

    return roomId;
  }

  Future<void> startGame(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'isGameStarted': true,
    });
  }

  // Odaya katıl
  Future<bool> joinRoom(String roomId, String playerName) async {
    final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
    if (!roomDoc.exists) return false;

    Room room = Room.fromMap(roomDoc.data() as Map<String, dynamic>);
    if (room.isGameStarted) return false;

    Player newPlayer = Player(id: currentUserId, name: playerName);
    room.players.add(newPlayer);

    await _firestore.collection('rooms').doc(roomId).update({
      'players': room.players.map((p) => p.toMap()).toList(),
    });

    return true;
  }

  // Oda akışını dinle
  Stream<Room> getRoomStream(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots().map((snapshot) {
      return Room.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }
}
