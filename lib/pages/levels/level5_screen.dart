import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_number.dart';
import '../db/db_hive.dart';

class Level5Screen extends StatefulWidget {
  const Level5Screen({super.key});

  @override
  State<Level5Screen> createState() => _Level5ScreenState();
}

class _Level5ScreenState extends State<Level5Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  final Map<String, int> fruitCode = {
    "watermelon.png": 4,
    "pear.png": 13,
    "strawberry.png": 14,
    "apple.png": 16,
    "mango.png": 18,
    "grape.png": 21,
  };

  final List<String> questions = [
    "mango.png",
    "apple.png",
    "grape.png",
    "strawberry.png",
    "pear.png",
    "watermelon.png",
  ];

  List<String> userInputs = List.filled(6, '');
  List<bool> rowCorrect = List.filled(6, false);
  int activeRow = 0;

  String? lastCheckedStatus;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  void handleKeyboard(String key) {
    setState(() {
      if (key == '←') {
        if (userInputs[activeRow].isNotEmpty) {
          userInputs[activeRow] = userInputs[activeRow]
              .substring(0, userInputs[activeRow].length - 1);
        } else {
          if (activeRow > 0) activeRow--;
        }
        return;
      }

      if (userInputs[activeRow].length < 2) {
        userInputs[activeRow] += key;
        if (userInputs[activeRow].length == 2 &&
            activeRow < userInputs.length - 1) {
          activeRow++;
        }
      }
    });

    autoCheckAnswers();
  }

  void autoCheckAnswers() async {
    for (int i = 0; i < userInputs.length; i++) {
      if (userInputs[i].isEmpty) return;
    }

    bool allCorrect = true;

    for (int i = 0; i < questions.length; i++) {
      int correctAnswer = fruitCode[questions[i]]!;
      bool ok = userInputs[i] == correctAnswer.toString();
      rowCorrect[i] = ok;
      if (!ok) allCorrect = false;
    }

    setState(() {});

    if (allCorrect) {
      await showResultDialog(true);
      hasWon = true;
      setState(() {});
    } else {
      await showResultDialog(false);
      restart();
    }
  }

  Future<void> showResultDialog(bool correct) async {
    setState(() {
      lastCheckedStatus = correct ? "correct" : "wrong";
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

  void restart() {
    setState(() {
      userInputs = List.filled(6, '');
      rowCorrect = List.filled(6, false);
      activeRow = 0;
      lastCheckedStatus = null;
      showWin = false;
      hasWon = false;
    });
  }

  Widget answerBox(int index) {
    Color borderColor = Colors.black;
    double borderWidth = 1.5;

    // aktif = biru (hanya sebelum dicek)
    if (lastCheckedStatus == null && index == activeRow) {
      borderColor = Colors.blue;
      borderWidth = 2.5;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: w(40),
      height: h(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white, // selalu putih
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(w(6)), // optional biar smooth
      ),
      child: Text(
        userInputs[index],
        style: TextStyle(
          fontSize: sp(20),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget questionRow(String fruit, int index) {
    return GestureDetector(
      onTap: () => setState(() => activeRow = index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/$fruit", width: w(40), height: h(40)),
          SizedBox(width: w(6)),
          Text("=", style: TextStyle(fontSize: sp(22))),
          SizedBox(width: w(6)),
          answerBox(index),
        ],
      ),
    );
  }

  /// ===============================
  /// GRID 1-25 MENYATU (TANPA JARAK)
  /// ===============================
  Widget buildGrid() {
    return Container(
      width: w(300),
      height: h(300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1), // border luar
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 25,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        itemBuilder: (context, index) {
          int num = index + 1;
          String? fruit;

          fruitCode.forEach((img, pos) {
            if (pos == num) fruit = img;
          });

          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: (index % 5 != 4) ? Colors.black : Colors.transparent,
                ),
                bottom: BorderSide(
                  color: (index < 20) ? Colors.black : Colors.transparent,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: fruit != null
                ? Image.asset("assets/images/$fruit", width: w(35))
                : Text(
                    "$num",
                    style: TextStyle(
                      fontSize: sp(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

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
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFF45B56B),
                      alignment: Alignment.center,
                      child: Text(
                        'ENCODE & DECODE',
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
                  "Tulis angka yang dimaksud",
                  style: TextStyle(fontSize: sp(16)),
                ),
                SizedBox(height: h(20)),
                buildGrid(),
                SizedBox(height: h(20)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: w(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /// ===== BARIS 1 =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            questionRow(questions[0], 0), // mango
                            questionRow(questions[1], 1), // apple
                            questionRow(questions[2], 2), // grape
                          ],
                        ),

                        /// ===== BARIS 2 =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            questionRow(questions[3], 3), // strawberry
                            questionRow(questions[4], 4), // pear
                            questionRow(questions[5], 5), // watermelon
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                NumberKeyboard(onKeyTap: handleKeyboard),
              ],
            ),
            if (showWin)
              Center(
                child: Lottie.asset(
                  winAnimasi!,
                  width: w(250),
                  repeat: false,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(5);

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
