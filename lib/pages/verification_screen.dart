import 'dart:math';
import 'package:flutter/material.dart';
import 'account_screen.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int a = 0;
  int b = 0;
  int correctAnswer = 0;

  List<int> options = [];

  bool isAnswered = false;
  int? selectedAnswer;
  int? pressedIndex;

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    final random = Random();

    a = random.nextInt(10) + 1;
    b = random.nextInt(10) + 1;
    correctAnswer = a + b;

    // 🔥 pakai set biar tidak duplikat
    final Set<int> tempOptions = {correctAnswer};

    while (tempOptions.length < 6) {
      int wrong = correctAnswer + random.nextInt(10) - 5;
      if (wrong > 0) tempOptions.add(wrong);
    }

    options = tempOptions.toList();
    options.shuffle();

    // reset state
    isAnswered = false;
    selectedAnswer = null;
  }

  void selectAnswer(int value) {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = value;
      isAnswered = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (value == correctAnswer) {
        // ✅ BENAR → pindah halaman
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountPage(),
          ),
        );
      } else {
        // ❌ SALAH → reset soal
        generateQuestion();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "KHUSUS ORANG TUA",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Untuk melanjutkan silahkan jawab pertanyaan dibawah ini :",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// SOAL + INPUT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$a + $b =",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// 🔥 BOX HASIL
                      Container(
                        width: 70,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6DCF4),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFBFABDE),
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Text(
                          selectedAnswer?.toString() ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 84),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.4,
                      children:
                          options.map((e) => answerButton(e)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔘 BUTTON
  Widget answerButton(int value) {
    final isPressed = pressedIndex == value;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressedIndex = value;
        });
      },
      onTapUp: (_) {
        setState(() {
          pressedIndex = null;
        });
      },
      onTapCancel: () {
        setState(() {
          pressedIndex = null;
        });
      },

      onTap: isAnswered ? null : () => selectAnswer(value),

      child: AnimatedScale(
        scale: isPressed ? 0.9 : 1.0, // 🔥 efek tekan real
        duration: const Duration(milliseconds: 100),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isAnswered
                ? Colors.grey
                : const Color(0xFF6CD400),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isAnswered
                    ? Colors.grey.shade700
                    : const Color(0xFF3A8F00),
                offset: isPressed ? const Offset(0, 2) : const Offset(0, 4),
              )
            ]
          ),
          child: Center(
            child: Text(
              "$value",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}