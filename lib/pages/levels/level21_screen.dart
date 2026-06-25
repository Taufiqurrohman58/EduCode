import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_number.dart';
import '../db/db_hive.dart';

class Level21Screen extends StatefulWidget {
  const Level21Screen({super.key});

  @override
  State<Level21Screen> createState() => _Level21ScreenState();
}

class _Level21ScreenState extends State<Level21Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// =========================
  /// JAWABAN BENAR
  /// =========================
  final List<int> correctAnswers = [1, 3, 2, 3, 1, 2, 3, 2, 1];

  /// INPUT USER
  List<String> userInputs = List.filled(9, '');

  int activeIndex = 0;

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;
  bool isChecking = false;

  /// =========================
  /// HANDLE KEYBOARD
  /// =========================
  void handleKeyboard(String key) {
    setState(() {
      if (key == '←') {
        if (userInputs[activeIndex].isNotEmpty) {
          userInputs[activeIndex] = '';
        } else {
          if (activeIndex > 0) activeIndex--;
        }
        return;
      }

      if (userInputs[activeIndex].isEmpty) {
        userInputs[activeIndex] = key;

        /// PINDAH KE BOX BERIKUTNYA
        for (int i = activeIndex + 1; i < userInputs.length; i++) {
          if (userInputs[i].isEmpty) {
            activeIndex = i;
            break;
          }
        }
      }
    });

    autoCheck();
  }

  /// =========================
  /// AUTO CHECK
  /// =========================
  void autoCheck() async {
    for (String val in userInputs) {
      if (val.isEmpty) return;
    }

    setState(() {
      isChecking = true; // 🔥 matikan highlight aktif
    });

    bool allCorrect = true;

    for (int i = 0; i < correctAnswers.length; i++) {
      if (userInputs[i] != correctAnswers[i].toString()) {
        allCorrect = false;
      }
    }

    if (allCorrect) {
      await showResultDialog(true);
      hasWon = true;
    } else {
      await showResultDialog(false);
      restart();
      return;
    }

    setState(() {});
  }

  /// =========================
  /// DIALOG RESULT
  /// =========================
  Future<void> showResultDialog(bool correct) async {
    setState(() {
      if (correct) {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      }
    });

    if (correct) {
      await AudioManager().playEffect('sounds/benar.mp3');
      await Future.delayed(const Duration(seconds: 2));
      setState(() => showWin = false);
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// =========================
  /// RESET
  /// =========================
  void restart() {
    setState(() {
      userInputs = List.filled(9, '');
      activeIndex = 0;
      showWin = false;
      hasWon = false;
      isChecking = false;
    });
  }

  /// =========================
  /// LINGKARAN INPUT
  /// =========================
  Widget answerCircle(int index) {
    Color borderColor = Colors.black;

    // 🔥 hanya tampilkan biru kalau BELUM cek
    if (!isChecking && index == activeIndex) {
      borderColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          activeIndex = index;
        });
      },
      child: Container(
        width: w(40),
        height: h(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
        ),
        child: Text(
          userInputs[index],
          style: TextStyle(
            fontSize: sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// ITEM GAMBAR + LINGKARAN
  /// =========================
  Widget sequenceItem(String image, int index) {
    return Column(
      children: [
        Image.asset(
          image,
          width: w(75),
          height: h(75),
        ),
        SizedBox(height: h(10)),
        answerCircle(index),
      ],
    );
  }

  /// =========================
  /// ROW SEQUENCE
  /// =========================
  Widget sequenceRow(List<String> images, int startIndex) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (i) => sequenceItem(images[i], startIndex + i),
        ),
      ),
    );
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// =========================
  /// BUILD UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // base width 360 (HP kecil)
    scale = screenWidth / 360;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                /// HEADER
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFFF79055),
                      alignment: Alignment.center,
                      child: Text(
                        'SEQUENCE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sp(18),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: w(18)),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: w(30),
                              height: h(30),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/images/back_icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: w(18)),
                          child: GestureDetector(
                            onTap: () async {
                              AudioManager().playVoice('sounds/level_1&2.mp3');
                            },
                            child: Container(
                              width: w(30),
                              height: h(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(w(8)),
                              ),
                              child: Transform.scale(
                                scale: 1.2,
                                child: Image.asset(
                                  "assets/images/volume.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h(20)),

                Text(
                  "Beri angka 1–3 sesuai urutan waktu",
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(20)),

                Expanded(
                  child: Column(
                    children: [
                      /// ROW 1
                      sequenceRow([
                        "assets/images/21/a1.png",
                        "assets/images/21/a2.png",
                        "assets/images/21/a3.png",
                      ], 0),

                      /// ROW 2
                      sequenceRow([
                        "assets/images/21/b1.png",
                        "assets/images/21/b2.png",
                        "assets/images/21/b3.png",
                      ], 3),

                      /// ROW 3
                      sequenceRow([
                        "assets/images/21/c1.png",
                        "assets/images/21/c2.png",
                        "assets/images/21/c3.png",
                      ], 6),
                    ],
                  ),
                ),

                /// KEYBOARD
                NumberKeyboard(onKeyTap: handleKeyboard),
              ],
            ),

            /// ANIMASI MENANG
            if (showWin)
              Center(
                child: Lottie.asset(
                  winAnimasi!,
                  width: h(250),
                  repeat: false,
                ),
              ),
          ],
        ),
      ),

      /// BUTTON LANJUT
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(21);

                    _nextLevel();

                    // _backPage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w(15)),
                      side: const BorderSide(
                        color: Colors.purple,
                        width: 3,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: w(20), vertical: h(12)),
                    elevation: 6,
                  ),
                  child: Text(
                    "Lanjut",
                    style: TextStyle(
                      fontSize: sp(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
