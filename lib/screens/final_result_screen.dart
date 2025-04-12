import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinalResultScreen extends StatelessWidget {
  final String correctAnswer;
  final List<Map<String, dynamic >> playerScores;
  final VoidCallback onNext;
  final String roomId; // Ekledik
  final String playerId; // Ekledik
  final bool isHost;

  const FinalResultScreen({
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
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sonuçlar'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: roomRef.collection('players').orderBy('score', descending: true).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = snapshot.data!.docs;

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final data = players[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Bilinmeyen';
              final score = data['score'] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == 0 ? Colors.amber : Colors.grey,
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  name,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  '$score puan',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: isHost
          ? Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          onPressed: () async {
            final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
            final batch = FirebaseFirestore.instance.batch();

            final playersSnapshot = await roomRef.collection('players').get();
            for (var doc in playersSnapshot.docs) {
              batch.update(doc.reference, {'score': 0});
            }

            await batch.commit();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          },
          child: const Text('Yeni Oyun Başlat'),
        ),
      )
          : null,
    );
  }
}
