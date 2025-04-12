import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteAnswerScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final List<Map<String, dynamic>> allAnswers;
  final String correctAnswer;
  final String playerName;
  final bool isHost;

  const VoteAnswerScreen({
    Key? key,
    required this.roomId,
    required this.playerId,
    required this.allAnswers,
    required this.correctAnswer,
    required this.playerName,
    required this.isHost,
  }) : super(key: key);

  @override
  State<VoteAnswerScreen> createState() => _VoteAnswerScreenState();
}

class _VoteAnswerScreenState extends State<VoteAnswerScreen> {
  String? _selectedAnswer;
  bool _isSubmitted = false;
  int _secondsLeft = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.allAnswers.shuffle(); // Karıştır
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsLeft == 0) {
        timer.cancel();
        if (!_isSubmitted) {
          await _submitVote();
        }
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _submitVote() async {
    _timer?.cancel();
    _isSubmitted = true;

    final vote = _selectedAnswer ?? "Boş";

    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);
    await roomRef.collection('votes').doc(widget.playerId).set({'vote': vote});

    // Puan hesaplaması sadece host tarafından yapılır
    if (widget.isHost) {
      final votesSnapshot = await roomRef.collection('votes').get();
      final playersSnapshot = await roomRef.collection('players').get();
      final totalPlayers = playersSnapshot.docs.length;

      if (votesSnapshot.docs.length == totalPlayers) {
        final scores = <String, int>{};

        for (var doc in votesSnapshot.docs) {
          final voterId = doc.id;
          final chosenAnswer = doc.data()['vote'];

          if (chosenAnswer == widget.correctAnswer) {
            // Doğru cevabı seçen oyuncuya puan
            scores[voterId] = (scores[voterId] ?? 0) + 100;
          } else {
            // Yanlış ama başka bir oyuncunun bluff cevabını seçtiyse ona puan yaz
            final bluffEntry = widget.allAnswers.firstWhere(
                  (e) => e['text'] == chosenAnswer,
              orElse: () => {},
            );

            if (bluffEntry.isNotEmpty && bluffEntry['playerId'] != null) {
              final bluffOwnerId = bluffEntry['playerId'];
              scores[bluffOwnerId] = (scores[bluffOwnerId] ?? 0) + 50;
            }
          }
        }

        // Puanları güncelle
        for (var entry in scores.entries) {
          final playerDoc = roomRef.collection('players').doc(entry.key);
          await playerDoc.set({'score': FieldValue.increment(entry.value)}, SetOptions(merge: true));
        }
      }
    }

    // Sonraki ekrana geçiş
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/final');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Cevabınızı Seçin ($_secondsLeft saniye)',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...widget.allAnswers.map((answer) {
              final text = answer['text'] ?? '';
              return RadioListTile<String>(
                title: Text(text, style: const TextStyle(color: Colors.white)),
                value: text,
                groupValue: _selectedAnswer,
                onChanged: _isSubmitted ? null : (val) => setState(() => _selectedAnswer = val),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitted ? null : _submitVote,
              child: const Text('Oy Ver'),
            ),
          ],
        ),
      ),
    );
  }
}
