import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseAnswerScreen extends StatefulWidget {
  final String questionText;
  final List<String> allAnswers;
  final Future<void> Function(String selectedAnswer) onSubmit;

  const ChooseAnswerScreen({
    Key? key,
    required this.questionText,
    required this.allAnswers,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _ChooseAnswerScreenState createState() => _ChooseAnswerScreenState();
}

class _ChooseAnswerScreenState extends State<ChooseAnswerScreen> {
  String? _selected;
  int _remainingSeconds = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_remainingSeconds == 0) {
        _timer?.cancel();
        await _autoSubmit();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _autoSubmit() async {
    // Süre bitince rastgele seçim yap veya boş gönder
    String autoSelectedAnswer = widget.allAnswers.first; // Rastgele ilk seçenek
    await widget.onSubmit(autoSelectedAnswer);
    if (mounted) Navigator.pop(context);
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
                widget.questionText,
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  color: Colors.cyanAccent,
                ),
              ),
              SizedBox(height: 20),

              //⏳ 20 Saniyelik Sayaç
              Center(
                child: Text(
                  "$_remainingSeconds sn kaldı",
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: widget.allAnswers.map((answer) {
                    return RadioListTile<String>(
                      title: Text(
                        answer,
                        style: TextStyle(color: Colors.white),
                      ),
                      value: answer,
                      groupValue: _selected,
                      onChanged: (val) {
                        setState(() => _selected = val);
                      },
                    );
                  }).toList(),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _selected == null
                    ? null
                    : () async {
                  _timer?.cancel();
                  await widget.onSubmit(_selected!);
                  if (mounted) Navigator.pop(context);
                },
                child: Text(
                  "Gönder",
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
