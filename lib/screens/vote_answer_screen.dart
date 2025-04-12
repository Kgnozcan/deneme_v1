import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deneme_v1/screens/result_screen.dart';
import 'package:deneme_v1/screens/final_result_screen.dart';

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
  String? selectedAnswer;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (!widget.isHost) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .snapshots()
          .listen((snapshot) {
        final data = snapshot.data();
        if (data != null && data['votesEvaluated'] == true) {
          _navigateToResultScreen();
        }
      });
    }
  }

  Future<void> _submitVote() async {
    if (selectedAnswer == null || isSubmitting) return;
    setState(() {
      isSubmitting = true;
    });

    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);

    final votedAnswer = selectedAnswer!;
    final roomSnapshot = await roomRef.get();
    final answers = (roomSnapshot.data()?['answers'] as List<dynamic>).cast<Map<String, dynamic>>();
    final playersSnapshot = await roomRef.collection('players').get();

    List<Map<String, dynamic>> updatedPlayerScores = [];

    for (var answer in answers) {
      if (answer['text'] == votedAnswer) {
        final answerOwnerId = answer['playerId'];

        for (var doc in playersSnapshot.docs) {
          final data = doc.data();
          int currentScore = data['score'] ?? 0;

          if (doc.id == widget.playerId && votedAnswer == widget.correctAnswer) {
            currentScore += 1000;
          }

          if (doc.id == answerOwnerId && votedAnswer != widget.correctAnswer) {
            currentScore += 500;
          }

          await roomRef.collection('players').doc(doc.id).update({'score': currentScore});

          updatedPlayerScores.add({
            'name': data['name'] ?? 'Unknown',
            'score': currentScore,
          });
        }
        break;
      }
    }

    await roomRef.collection('votes').doc(widget.playerId).set({'voted': true});

    final votesSnapshot = await roomRef.collection('votes').get();
    final allVoted = votesSnapshot.docs.length == playersSnapshot.docs.length;

    if (allVoted) {
      print('✅ Oy veren herkes tamamladı...');
      if (widget.isHost) {
        await roomRef.update({'votesEvaluated': true});
        _navigateToResultScreen();
      }
    }
  }

  void _navigateToResultScreen() async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);
    final roomSnapshot = await roomRef.get();
    final currentRound = roomSnapshot.data()?['currentRound'] ?? 1;
    final totalRounds = roomSnapshot.data()?['totalRounds'] ?? 1;

    final playersSnapshot = await roomRef.collection('players').get();
    List<Map<String, dynamic>> updatedPlayerScores = [];

    for (var doc in playersSnapshot.docs) {
      final data = doc.data();
      updatedPlayerScores.add({
        'name': data['name'] ?? 'Unknown',
        'score': data['score'] ?? 0,
      });
    }

    if (!mounted) return;

    if (currentRound >= totalRounds) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FinalResultScreen(
            roomId: widget.roomId,
            playerId: widget.playerId,
            correctAnswer: widget.correctAnswer,
            playerScores: updatedPlayerScores,
            onNext: () {},
            isHost: widget.isHost,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            roomId: widget.roomId,
            playerId: widget.playerId,
            correctAnswer: widget.correctAnswer,
            playerScores: updatedPlayerScores,
            onNext: () {},
            isHost: widget.isHost,
          ),
        ),
      );
    }
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
            const Text(
              'Cevabınızı seçin:',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...widget.allAnswers.map((answer) {
              return ListTile(
                title: Text(
                  answer['text'],
                  style: const TextStyle(color: Colors.white),
                ),
                leading: Radio<String>(
                  value: answer['text'],
                  groupValue: selectedAnswer,
                  onChanged: (value) {
                    setState(() {
                      selectedAnswer = value;
                    });
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitVote,
              child: const Text('Oy Ver'),
            ),
          ],
        ),
      ),
    );
  }
}