import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseAnswerScreen extends StatefulWidget {
  final String questionText;
  final List<String> allAnswers;
  final void Function(String selectedAnswer) onSubmit;

  const ChooseAnswerScreen({
    Key? key,
    required this.questionText,
    required this.allAnswers,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ChooseAnswerScreen> createState() => _ChooseAnswerScreenState();
}

class _ChooseAnswerScreenState extends State<ChooseAnswerScreen> {
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Yanıt Seç", style: GoogleFonts.orbitron()),
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.questionText,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: widget.allAnswers.length,
                itemBuilder: (context, index) {
                  final answer = widget.allAnswers[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedAnswer == answer
                            ? Colors.pinkAccent
                            : Colors.cyanAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        answer,
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      value: answer,
                      groupValue: selectedAnswer,
                      activeColor: Colors.pinkAccent,
                      onChanged: (value) {
                        setState(() {
                          selectedAnswer = value;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedAnswer == null
                  ? null
                  : () => widget.onSubmit(selectedAnswer!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Cevabımı Gönder',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
