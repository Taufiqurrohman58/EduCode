import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';
import '../widgets/keyboard_number.dart';

class Level20Screen extends StatefulWidget {
  const Level20Screen({super.key});

  @override
  State<Level20Screen> createState() => _Level20ScreenState();
}

class _Level20ScreenState extends State<Level20Screen> {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  final List<String> userInputs = List.filled(3, '');
  List<bool> correct = [false, false, false];

  String? lastCheckedStatus;
  int activeIndex = 0;

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  /// JAWABAN
  final List<String> answers = ["7", "6", "4"];

  /// HANDLE INPUT
  void handleInput(String key) {
    setState(() {
      if (key == '←') {
        if (userInputs[activeIndex].isNotEmpty) {
          userInputs[activeIndex] = '';
        } else if (activeIndex > 0) {
          activeIndex--;
          userInputs[activeIndex] = '';
        }
        return;
      }

      // max 1 digit
      if (userInputs[activeIndex].isEmpty) {
        userInputs[activeIndex] = key;

        if (activeIndex < userInputs.length - 1) {
          activeIndex++;
        }
      }
    });

    autoCheck();
  }

  /// AUTO CHECK
  void autoCheck() async {
    for (var input in userInputs) {
      if (input.isEmpty) return;
    }

    bool allCorrect = true;

    for (int i = 0; i < userInputs.length; i++) {
      correct[i] = userInputs[i] == answers[i];
      if (!correct[i]) allCorrect = false;
    }

    setState(() {});

    if (allCorrect) {
      hasWon = true;
      await showResult(true);
      setState(() {});
    } else {
      await showResult(false);
      restart();
    }
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// RESULT
  Future<void> showResult(bool isCorrect) async {
    setState(() {
      lastCheckedStatus = isCorrect ? "correct" : "wrong";
      if (isCorrect) {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      }
    });

    if (isCorrect) {
      await AudioManager().playEffect('sounds/benar.mp3');
      await Future.delayed(const Duration(seconds: 3));
      setState(() => showWin = false);
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// RESET
  void restart() {
    setState(() {
      userInputs.fillRange(0, userInputs.length, '');
      correct = [false, false, false];
      lastCheckedStatus = null;
      activeIndex = 0;
      hasWon = false;
      showWin = false;
    });
  } 

  /// BOX UI
  Widget numberBox(int index) {
    Color borderColor = Colors.black;
    double borderWidth = 2;

    // 🔥 hanya tampilkan biru kalau BELUM check
    if (lastCheckedStatus == null && index == activeIndex) {
      borderColor = Colors.blue;
      borderWidth = 3;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: w(45),
      height: h(45),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(w(6)),
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

  /// ITEM
  Widget questionItem({
    required int index,
    required String image,
    required String question,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          activeIndex = index;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(image, width: double.infinity, fit: BoxFit.contain),
          SizedBox(height: h(10)),
          Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(fontSize: sp(16)),
                ),
              ),
              numberBox(index),
            ],
          ),
          SizedBox(height: h(25)),
        ],
      ),
    );
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
                /// HEADER
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFF6E64AB),
                      alignment: Alignment.center,
                      child: Text(
                        'LOOPS',
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

                SizedBox(height: h(16)),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: w(25)),
                    child: Column(
                      children: [
                        questionItem(
                          index: 0,
                          image: "assets/images/20/1.png",
                          question: "Berapa gigi yang harus ia sikat?",
                        ),
                        questionItem(
                          index: 1,
                          image: "assets/images/20/2.png",
                          question: "Berapa ban yang harus ia tambal?",
                        ),
                        questionItem(
                          index: 2,
                          image: "assets/images/20/3.png",
                          question: "Berapa donat yang harus ia buat?",
                        ),
                      ],
                    ),
                  ),
                ),

                /// KEYBOARD
                NumberKeyboard(onKeyTap: handleInput),
              ],
            ),

            /// WIN ANIMATION
            if (showWin && winAnimasi != null)
              Center(
                child: Lottie.asset(
                  winAnimasi!,
                  width: w(250),
                  height: h(250),
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
                    await DBHive.unlockNextLevel(20);

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
