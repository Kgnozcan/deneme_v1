import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnterBluffScreen extends StatefulWidget {
  final String questionText;
  final Future<void> Function(String bluff) onSubmit;

  const EnterBluffScreen({
    Key? key,
    required this.questionText,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _EnterBluffScreenState createState() => _EnterBluffScreenState();
}

class _EnterBluffScreenState extends State<EnterBluffScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  int _remainingSeconds = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        _timer?.cancel();
        _autoSubmit();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _autoSubmit() async {
    List<String> defaultFakeAnswers = [
      "Berlin", "Paris", "Roma", "Tokyo", "Madrid", "Londra", "New York"
    ]..shuffle();

    String autoBluff = defaultFakeAnswers.first;
    await widget.onSubmit(autoBluff);
  }


  Future<void> _handleSubmit() async {
    if (_controller.text.trim().isEmpty) return;

    _timer?.cancel();

    setState(() {
      _submitting = true;
    });

    await widget.onSubmit(_controller.text.trim());

    if (mounted) {
      Navigator.pop(context);
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Soru:",
                style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                widget.questionText,
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 32),

              // ⏳ Sayaç Görseli
              Center(
                child: Text(
                  "$_remainingSeconds saniye",
                  style: GoogleFonts.orbitron(
                    color: Colors.redAccent,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: "Yanıltıcı cevap gir",
                  labelStyle: const TextStyle(color: Colors.cyanAccent),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Gönder", style: GoogleFonts.orbitron(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
