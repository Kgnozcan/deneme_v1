import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';
import '../models/player.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // 4 haneli rastgele oda kodu üret
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      List.generate(4, (_) => chars.codeUnitAt(Random().nextInt(chars.length))),
    );
  }

  // Oda oluştur
  Future<String> createRoom(String roomName, String hostName) async {
    final String roomId = _generateRoomCode();

    Player host = Player(id: currentUserId, name: hostName, isHost: true);
    Room newRoom = Room(id: roomId, name: roomName, players: [host]);

    await _firestore.collection('rooms').doc(roomId).set({
      ...newRoom.toMap(),
      'currentRound': 0,
      'maxRounds': 5,
      'questions': [
        {'text': 'Dünyanın en büyük okyanusu nedir?', 'correctAnswer': 'Pasifik'},
        {'text': 'Ay hangi gezegene aittir?', 'correctAnswer': 'Dünya'},
        {'text': 'En hızlı kara hayvanı?', 'correctAnswer': 'Çita'},
        {'text': 'İstanbul hangi kıtada yer alır?', 'correctAnswer': 'Avrupa ve Asya'},
        {'text': 'Işık yılı neyi ölçer?', 'correctAnswer': 'Mesafe'},
      ],
      'answers': [],
      'votes': [],
      'showResults': false,
    });

    return roomId;
  }

  Future<void> startGame(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'isGameStarted': true,
    });
  }

  Future<void> submitAnswer(String roomId, String playerId, String answerText) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);

    // 1. Alt koleksiyona cevabı yaz (gerekirse burada saklamaya devam edebilirsin)
    await roomRef.collection('answers').doc(playerId).set({
      'answer': answerText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Ana dokümandaki cevaplar listesine benzersiz olarak ekle (playerId ile birlikte)
    final uniqueAnswer = '$answerText|$playerId';
    await roomRef.update({
      'answers': FieldValue.arrayUnion([uniqueAnswer])
    });
  }




  Future<void> submitVote(String roomId, String playerId, String votedPlayerId) async {
    await _firestore.collection('rooms').doc(roomId).collection('votes').doc(playerId).set({
      'votedPlayerId': votedPlayerId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> calculateVotesAndScore(String roomId, String correctPlayerId) async {
    final votesSnapshot = await _firestore.collection('rooms').doc(roomId).collection('votes').get();

    final roomRef = _firestore.collection('rooms').doc(roomId);
    final roomDoc = await roomRef.get();
    final roomData = roomDoc.data()!;
    final players = (roomData['players'] as List<dynamic>).map((p) => Map<String, dynamic>.from(p)).toList();

    for (var vote in votesSnapshot.docs) {
      final voterId = vote.id;
      final votedPlayerId = vote['votedPlayerId'];

      for (var player in players) {
        if (player['id'] == voterId && votedPlayerId == correctPlayerId) {
          player['score'] = (player['score'] ?? 0) + 100;
        }

        if (player['id'] == votedPlayerId && votedPlayerId != correctPlayerId) {
          player['score'] = (player['score'] ?? 0) + 50;
        }
      }
    }

    await roomRef.update({
      'players': players,
      'votesEvaluated': true,
    });

    final batch = _firestore.batch();
    for (var vote in votesSnapshot.docs) {
      batch.delete(vote.reference);
    }
    await batch.commit();
  }

  Future<void> goToNextRound(String roomId) async {
    final docRef = _firestore.collection('rooms').doc(roomId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final roomData = snapshot.data() as Map<String, dynamic>;
    final currentRound = roomData['currentRound'] ?? 0;
    final maxRounds = roomData['maxRounds'] ?? 5;

    if (currentRound + 1 >= maxRounds) {
      await docRef.update({'showResults': true});
      return;
    }

    await docRef.update({
      'currentRound': currentRound + 1,
      'answers': [],
      'votes': [],
      'showResults': false,
    });
  }

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

  Stream<Room> getRoomStream(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots().map((snapshot) {
      return Room.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }
}
