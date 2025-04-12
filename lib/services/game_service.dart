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

    // Sorulara fakeAnswers eklendi
    final questions = [
      {
        'text': 'Dünyanın en büyük okyanusu nedir?',
        'correctAnswer': 'Pasifik',
        'fakeAnswers': ['Atlantik', 'Hint', 'Arktik', 'Akdeniz'],
      },
      {
        'text': 'Ay hangi gezegene aittir?',
        'correctAnswer': 'Dünya',
        'fakeAnswers': ['Mars', 'Venüs', 'Satürn', 'Jüpiter'],
      },
      {
        'text': 'En hızlı kara hayvanı?',
        'correctAnswer': 'Çita',
        'fakeAnswers': ['Tavşan', 'Aslan', 'At', 'Kaplan'],
      },
      {
        'text': 'İstanbul hangi kıtada yer alır?',
        'correctAnswer': 'Avrupa ve Asya',
        'fakeAnswers': ['Sadece Avrupa', 'Sadece Asya', 'Afrika', 'Antarktika'],
      },
      {
        'text': 'Işık yılı neyi ölçer?',
        'correctAnswer': 'Mesafe',
        'fakeAnswers': ['Zaman', 'Hız', 'Yoğunluk', 'Kütle'],
      },
    ];

    await _firestore.collection('rooms').doc(roomId).set({
      ...newRoom.toMap(),
      'currentRound': 0,
      'maxRounds': questions.length,
      'questions': questions,
      'answers': [],
      'votes': [],
      'showResults': false,
      'votesEvaluated': false,
    });

    return roomId;
  }

  Future<void> setShowResults(String roomId, bool value) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'showResults': value,
    });
  }

  Future<void> setVotesEvaluated(String roomId, bool evaluated) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .update({'votesEvaluated': evaluated});
  }

  Future<void> startGame(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'isGameStarted': true,
    });
  }

  Future<void> submitAnswer(String roomId, String playerId, String answerText) async {
    if (roomId.isEmpty || playerId.isEmpty || answerText.isEmpty) {
      print('❌ submitAnswer: Parametrelerden biri boş! ➤ roomId: $roomId | playerId: $playerId | answerText: $answerText');
      return;
    }

    final roomRef = _firestore.collection('rooms').doc(roomId);

    try {
      // 1. Alt koleksiyona cevabı yaz
      await roomRef.collection('answers').doc(playerId).set({
        'answer': answerText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Alt koleksiyona cevap yazıldı: $answerText');

      // 2. Mevcut cevapları al
      final roomSnap = await roomRef.get();
      final data = roomSnap.data() as Map<String, dynamic>;
      final answers = List<String>.from(data['answers'] ?? []);

      // 3. Eski cevabı çıkar ve yenisini ekle
      final updatedAnswers = answers.where((a) => !a.endsWith('|$playerId')).toList();
      updatedAnswers.add(answerText);

      // 4. Güncelle
      await roomRef.update({'answers': updatedAnswers});
      print('✅ Ana dokümana cevap eklendi: $answerText');
    } catch (e) {
      print('❌ submitAnswer sırasında hata oluştu: $e');
    }
  }



  Future<void> markVotesEvaluated(String roomId) async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
    await roomRef.update({
      'votesEvaluated': true,
    });
  }



  Future<void> submitVote(String roomId, String playerId, String votedPlayerId) async {
    await _firestore.collection('rooms').doc(roomId).collection('votes').doc(playerId).set({
      'votedPlayerId': votedPlayerId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> calculateVotesAndScore(String roomId, String correctAnswer) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);
    final roomDoc = await roomRef.get();
    final roomData = roomDoc.data()!;
    final players = (roomData['players'] as List<dynamic>)
        .map((p) => Map<String, dynamic>.from(p))
        .toList();

    final answers = List<String>.from(roomData['answers'] ?? []);
    final votesSnapshot = await roomRef.collection('votes').get();

    // 🧠 Doğru cevabı bluff olarak giren oyuncunun ID'si
    String? correctBluffPlayerId;
    for (var ans in answers) {
      final parts = ans.split('|');
      if (parts[0].toLowerCase().trim() == correctAnswer.toLowerCase().trim()) {
        correctBluffPlayerId = parts.length > 1 ? parts[1] : null;
        break;
      }
    }

    for (var vote in votesSnapshot.docs) {
      final voterId = vote.id;
      final votedPlayerId = vote['votedPlayerId'];

      for (var player in players) {
        if (player['id'] == voterId && votedPlayerId == correctBluffPlayerId) {
          // Doğru cevabı seçen oyuncu +100
          player['score'] = (player['score'] ?? 0) + 100;
        }

        if (player['id'] == votedPlayerId && votedPlayerId != correctBluffPlayerId) {
          // Kandıran oyuncuya +50
          player['score'] = (player['score'] ?? 0) + 50;
        }

        if (player['id'] == correctBluffPlayerId && votedPlayerId == correctBluffPlayerId) {
          // Doğru cevabı bluff olarak giren oyuncuya +25 bonus
          player['score'] = (player['score'] ?? 0) + 25;
        }
      }
    }

    await roomRef.update({
      'players': players,
      'votesEvaluated': true,
    });

    // Oyları temizle
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
