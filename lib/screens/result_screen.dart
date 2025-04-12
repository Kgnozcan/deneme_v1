import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  final String correctAnswer;
  final List<Map<String, dynamic >> playerScores;
  final VoidCallback onNext;
  final String roomId; // Ekledik
  final String playerId; // Ekledik
  final bool isHost;

  const ResultScreen({
    Key? key,
    required this.roomId,
    required this.playerId,
    required this.correctAnswer,
    required this.playerScores,
    required this.isHost,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '✅ Doğru Cevap:\n$correctAnswer',
              style: const TextStyle(fontSize: 28, color: Colors.greenAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              '🏆 Skor Tablosu',
              style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 20),
            ...playerScores.map((player) => Text(
              '${player['name']}: ${player['score']} puan',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            )),

            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: onNext,
              child: const Text('Sonraki Tur'),
            ),
          ],
        ),
      ),
    );
  }
}