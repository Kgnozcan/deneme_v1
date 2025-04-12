import 'package:flutter/material.dart';
import 'dart:async';

class ChooseAnswerScreen extends StatefulWidget {
  final String questionText;
  final List<String> allAnswers;
  final Future<void> Function(String) onSubmit;

  const ChooseAnswerScreen({
    required this.questionText,
    required this.allAnswers,
    required this.onSubmit,
    Key? key, required String playerId, required String roomId,
  }) : super(key: key);

  @override
  _ChooseAnswerScreenState createState() => _ChooseAnswerScreenState();
}

class _ChooseAnswerScreenState extends State<ChooseAnswerScreen> {
  String? selectedAnswer;
  Timer? _timer;
  int _secondsRemaining = 20;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        _submitAnswer();
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _submitAnswer() async {
    if (selectedAnswer != null) {
      await widget.onSubmit(selectedAnswer!);
      if (mounted) Navigator.pop(context);
    } else {
      // Seçilmemişse otomatik pop
      await widget.onSubmit('');
      if (mounted) Navigator.pop(context);
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.questionText,
              style: const TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '$_secondsRemaining saniye',
              style: const TextStyle(fontSize: 20, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            ...widget.allAnswers.map((answer) => RadioListTile<String>(
              title: Text(answer, style: const TextStyle(color: Colors.white)),
              value: answer,
              groupValue: selectedAnswer,
              onChanged: (value) {
                setState(() {
                  selectedAnswer = value;
                });
              },
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedAnswer == null ? null : _submitAnswer,
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
