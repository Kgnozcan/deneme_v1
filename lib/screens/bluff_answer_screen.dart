import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deneme_v1/screens/vote_answer_screen.dart';

class BluffAnswerScreen extends StatefulWidget {
  final String roomId;
  final String playerId;

  const BluffAnswerScreen({
    Key? key,
    required this.roomId,
    required this.playerId,
  }) : super(key: key);

  @override
  State<BluffAnswerScreen> createState() => _BluffAnswerScreenState();
}

class _BluffAnswerScreenState extends State<BluffAnswerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  int _secondsLeft = 15;
  Timer? _timer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        if (!_submitted) {
          _submitted = true;
          _timer?.cancel();
          _handleMissingAnswers();
        }
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _submitBluff({bool fake = false}) async {
    if (_submitted) return;

    _submitted = true;
    _timer?.cancel();

    if (fake) {
      print("⏩ Fake modda, veri yazılmadan çıkılıyor.");
      await _handleMissingAnswers();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String answerText = _controller.text.trim();
    if (answerText.isEmpty) {
      print("❌ Cevap boş, kayıt yapılmadı.");
      return;
    }

    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);

    await roomRef.update({
      'answers': FieldValue.arrayUnion([
        {"text": answerText, "playerId": widget.playerId}
      ])
    });

    await roomRef.collection('answers').doc(widget.playerId).set({
      'answer': answerText,
    });

    await _handleMissingAnswers();
  }

  Future<void> _handleMissingAnswers() async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);
    final roomSnapshot = await roomRef.get();
    List<dynamic> answerList = roomSnapshot.data()?['answers'] ?? [];
    final playersSnapshot = await roomRef.collection('players').get();
    final correctAnswer = roomSnapshot.data()?['correctAnswer'] ?? 'Doğru Cevap Yok';

    final playerCount = playersSnapshot.docs.length;
    final validAnswers = answerList
        .where((a) =>
    a['playerId'] != null &&
        a['text'] != null &&
        (a['text'] as String).trim().isNotEmpty &&
        a['playerId'] != widget.playerId)
        .toList();

    final missingCount = max(0, playerCount - validAnswers.length);

    if (missingCount > 0) {
      final questionsSnapshot = await FirebaseFirestore.instance.collection('questions').get();
      final allFakeAnswers = questionsSnapshot.docs
          .expand((doc) => (doc.data()['fakeAnswers'] as List<dynamic>).cast<String>())
          .toList();
      allFakeAnswers.shuffle();

      final additionalAnswers = allFakeAnswers.take(missingCount).map((answer) => {
        "text": answer,
        "playerId": null,
      }).toList();

      await roomRef.update({
        'answers': FieldValue.arrayUnion(additionalAnswers),
      });

      answerList.addAll(additionalAnswers);
    }

    final allAnswers = List<Map<String, dynamic>>.from(answerList)
        .where((a) => a['text'] != null && (a['text'] as String).trim().isNotEmpty)
        .toList();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoteAnswerScreen(
            roomId: widget.roomId,
            playerId: widget.playerId,
            allAnswers: allAnswers,
            correctAnswer: correctAnswer,
            playerName: 'Oyuncu',
            isHost: false,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Yanıltıcı Cevabınızı Girin ($_secondsLeft saniye)',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Bluff cevabınızı yazın',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => _submitBluff(),
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}