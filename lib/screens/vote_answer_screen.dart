import 'package:flutter/material.dart';
import '../services/game_service.dart';

class VoteAnswerScreen extends StatefulWidget {
  final String roomId;
  final String playerId;
  final List<Map<String, dynamic>> allAnswers;
  final String correctAnswer;

  const VoteAnswerScreen({
    Key? key,
    required this.roomId,
    required this.playerId,
    required this.allAnswers,
    required this.correctAnswer,
  }) : super(key: key);

  @override
  _VoteAnswerScreenState createState() => _VoteAnswerScreenState();
}

class _VoteAnswerScreenState extends State<VoteAnswerScreen> {
  final GameService _gameService = GameService();
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cevapları Oyla")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Sence doğru cevap hangisi?",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: widget.allAnswers.map((answerMap) {
                  final text = answerMap['text'] as String;
                  final playerId = answerMap['playerId'] ?? '';

                  return RadioListTile<String>(
                    title: Text(text),
                    value: playerId,
                    groupValue: _selected,
                    onChanged: (value) {
                      setState(() => _selected = value);
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () async {
                await _gameService.submitVote(widget.roomId, widget.playerId, _selected!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Oyun sonucu bekleniyor...')),
                );
                Navigator.pop(context); // Şimdilik oylamadan sonra geri dön
              },
              child: Text("Oyu Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}
