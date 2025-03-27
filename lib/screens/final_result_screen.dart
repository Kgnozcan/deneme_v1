import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalResultScreen extends StatelessWidget {
  final Map<String, int> playerScores;
  final VoidCallback onRestart;

  const FinalResultScreen({
    Key? key,
    required this.playerScores,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // En yüksek puanlı oyuncuyu bul
    final sortedPlayers = playerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final winner = sortedPlayers.first;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              "🎉 Oyun Bitti!",
              style: GoogleFonts.orbitron(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Kazanan: ${winner.key}",
              style: GoogleFonts.orbitron(
                fontSize: 22,
                color: Colors.yellowAccent,
              ),
            ),
            Text(
              "${winner.value} puan",
              style: GoogleFonts.orbitron(
                fontSize: 18,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Skor Tablosu",
              style: GoogleFonts.orbitron(
                fontSize: 20,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  final entry = sortedPlayers[index];
                  return ListTile(
                    title: Text(
                      entry.key,
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      "${entry.value} puan",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Ana Menüye Dön',
                style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
