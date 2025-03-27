import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BluffAnswerScreen extends StatefulWidget {
  final String questionText;
  final String roomId;
  final String playerId;

  const BluffAnswerScreen({
    Key? key,
    required this.questionText,
    required this.roomId,
    required this.playerId,
  }) : super(key: key);

  @override
  _BluffAnswerScreenState createState() => _BluffAnswerScreenState();
}

class _BluffAnswerScreenState extends State<BluffAnswerScreen> {
  final TextEditingController _bluffController = TextEditingController();
  bool _isSubmitting = false;

  void _submitBluff() async {
    if (_bluffController.text.isEmpty) return;

    setState(() => _isSubmitting = true);

    // TODO: Firestore'a yanıltıcı cevabı gönder (sonraki adımda yapılacak)

    await Future.delayed(Duration(seconds: 1)); // sahte bekleme

    Navigator.pushReplacementNamed(context, '/voteScreen'); // Oy verme ekranına yönlendirme
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Bluff Cevap Yaz'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              widget.questionText,
              style: GoogleFonts.orbitron(
                color: Colors.cyanAccent,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            TextField(
              controller: _bluffController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Yanıltıcı cevabınızı yazın',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBluff,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: GoogleFonts.orbitron(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
