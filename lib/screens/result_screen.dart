import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  final String correctAnswer;
  final Map<String, int> playerScores; // Oyuncu adı -> puan
  final VoidCallback onNext;

  const ResultScreen({
    Key? key,
    required this.correctAnswer,
    required this.playerScores,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = playerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              "✅ Doğru Cevap",
              style: GoogleFonts.orbitron(fontSize: 22, color: Colors.greenAccent),
            ),
            const SizedBox(height: 12),
            Text(
              correctAnswer,
              style: GoogleFonts.orbitron(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              "🏆 Skor Tablosu",
              style: GoogleFonts.orbitron(fontSize: 18, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  final entry = sortedPlayers[index];
                  final name = entry.key;
                  final score = entry.value;
                  return ListTile(
                    leading: Icon(Icons.person, color: Colors.amberAccent),
                    title: Text(
                      name,
                      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16),
                    ),
                    trailing: Text(
                      "+$score puan",
                      style: GoogleFonts.orbitron(color: Colors.yellowAccent, fontSize: 16),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Sonraki Tura Geç',
                style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
