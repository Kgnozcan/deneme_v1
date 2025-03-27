import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/game_service.dart';
import 'enter_bluff_screen.dart';
import 'choose_answer_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String playerName;
  final bool isHost;

  const GameScreen({
    Key? key,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.isHost,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  late Stream<DocumentSnapshot> _roomStream;
  bool hasNavigatedToBluff = false;
  bool hasNavigatedToVote = false;
  bool hasNavigatedToResult = false;
  bool hasCalculatedScore = false;

  @override
  void initState() {
    super.initState();
    _roomStream = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots();
  }

  void _navigateToEnterBluff(String questionText) {
    if (!hasNavigatedToBluff) {
      hasNavigatedToBluff = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterBluffScreen(
              questionText: questionText,
              onSubmit: (bluffText) async {
                await _gameService.submitAnswer(
                  widget.roomId,
                  widget.playerId,
                  "$bluffText|${widget.playerId}", // burada birleştirme yapılıyor
                );
                Navigator.pop(context);
              },
            ),
          ),
        );
      });
    }
  }

  void _navigateToChooseAnswer(String questionText, List<String> allAnswers) {
    if (!hasNavigatedToVote) {
      hasNavigatedToVote = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChooseAnswerScreen(
              questionText: questionText,
              allAnswers: allAnswers,
              onSubmit: (selectedAnswer) async {
                final parts = selectedAnswer.split('|');
                final votedPlayerId = parts.length > 1 ? parts[1] : '';
                await _gameService.submitVote(
                  widget.roomId,
                  widget.playerId,
                  votedPlayerId,
                );
                Navigator.pop(context);
              },
            ),
          ),
        );
      });
    }
  }

  void _navigateToResultScreen(String correctAnswer, List<dynamic> players) {
    if (!hasNavigatedToResult) {
      hasNavigatedToResult = true;

      final playerScores = {
        for (var p in players)
          p['name'] as String: (p['score'] ?? 0) as int
      };

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              correctAnswer: correctAnswer,
              playerScores: playerScores,
              onNext: () async {
                await _gameService.goToNextRound(widget.roomId);
                hasNavigatedToBluff = false;
                hasNavigatedToVote = false;
                hasNavigatedToResult = false;
                hasCalculatedScore = false;
              },
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Oyun Ekranı')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _roomStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final roomData = snapshot.data!.data() as Map<String, dynamic>;
          final currentRound = roomData['currentRound'] ?? 0;
          final question = roomData['questions']?[currentRound];
          final answersRaw = roomData['answers'] ?? [];
          final answers = List<String>.from(answersRaw.whereType<String>());
          final correctAnswer = question?['correctAnswer'] ?? '';
          final players = List.from(roomData['players'] ?? []);
          final votesEvaluated = roomData['votesEvaluated'] ?? false;
          final showResults = roomData['showResults'] ?? false;

          final playerAlreadyAnswered = answers.any((a) => a.endsWith('|${widget.playerId}'));

          if (question != null && !playerAlreadyAnswered) {
            _navigateToEnterBluff(question['text']);
          } else if (answers.length == players.length && !votesEvaluated) {
            final cleanedAnswers = answers.map((a) => a.split('|')[0]).toList();
            final allAnswers = List<String>.from([...cleanedAnswers, correctAnswer])..shuffle();
          } else if (votesEvaluated && !hasNavigatedToResult) {
            if (widget.isHost && !hasCalculatedScore) {
              hasCalculatedScore = true;
              _gameService.calculateVotesAndScore(widget.roomId, correctAnswer);
            }
            _navigateToResultScreen(correctAnswer, players);
          }

          if (showResults) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🎉 Oyun Bitti!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tüm turlar tamamlandı.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text('Ana Sayfaya Dön'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'Soru: ${question?['text'] ?? 'Yükleniyor...'}\n\nCevaplar geliyor...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
