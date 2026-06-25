import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level19Screen extends StatefulWidget {
  const Level19Screen({super.key});

  @override
  State<Level19Screen> createState() => _Level19ScreenState();
}

class _Level19ScreenState extends State<Level19Screen> {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// =========================
  /// JAWABAN BENAR
  /// =========================
  final Map<int, int> correctAnswers = {
    1: 3,
    2: 4,
    3: 8,
  };

  /// SELECTED
  Map<int, int?> selectedAnswers = {
    1: null,
    2: null,
    3: null,
  };



  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  bool get allSelected => selectedAnswers.values.every((e) => e != null);

  void restartLevel() {
    setState(() {
      selectedAnswers.updateAll((key, value) => null);
 
      hasWon = false;
    });
  }

  void autoCheckAnswer() async {
    if (!allSelected || hasWon) return;

    bool allCorrect = true;

    for (int row = 1; row <= 3; row++) {
      if (selectedAnswers[row] == correctAnswers[row]) {
      } else {
        allCorrect = false;
      }
    }

    setState(() {});

    if (allCorrect) {
      hasWon = true;

      setState(() {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      });

      await AudioManager().playEffect('sounds/benar.mp3');

      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        showWin = false;
      });
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');

      await Future.delayed(const Duration(seconds: 1));

      restartLevel();
    }
  }

  /// =========================
  /// GRID GAMBAR
  /// =========================
  Widget imageGrid(int itemCount, int crossAxisCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(12)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          return Image.asset(
            index % 2 == 0
                ? "assets/images/apple.png"
                : "assets/images/orange.png",
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }

  /// =========================
  /// TEXT SOAL
  /// =========================
  Widget questionText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Berapa kali muncul pola "),
        Image.asset("assets/images/apple.png", width: w(24)),
        SizedBox(width: w(4)),
        Image.asset("assets/images/orange.png", width: w(24)),
        const Text(" ?"),
      ],
    );
  }

  /// =========================
  /// NUMBER ROW (CLICKABLE)
  /// =========================
  Widget numberRow(int row, int total) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(total, (index) {
        int number = index + 1;
        bool isSelected = selectedAnswers[row] == number;

        Color borderColor = Colors.transparent;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAnswers[row] = number;
            });

            Future.delayed(
              const Duration(milliseconds: 300),
              autoCheckAnswer,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: w(30),
                height: h(30),
                margin: EdgeInsets.all(w(4)),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(w(8)),
                ),
                child: Center(
                  child: Text(
                    "$number",
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              /// ARROW
              if (isSelected)
                Image.asset(
                  "assets/images/arrow.png",
                  width: w(30),
                  height: h(30),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// =========================
  /// SECTION
  /// =========================
  Widget section(int row, int itemCount, int crossAxisCount) {
    return Column(
      children: [
        imageGrid(itemCount, crossAxisCount),
        SizedBox(height: h(10)),
        questionText(),
        SizedBox(height: h(10)),
        numberRow(row, crossAxisCount),
        SizedBox(height: h(25)),
      ],
    );
  }

  void _nextLevel() async {
    await DBHive.unlockNextLevel(19);
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
            SingleChildScrollView(
              child: Column(
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
                                AudioManager()
                                    .playVoice('sounds/level_1&2.mp3');
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

                  SizedBox(height: h(40)),

                  /// ROW 1
                  section(1, 6, 6),

                  /// ROW 2
                  section(2, 8, 8),

                  /// ROW 3
                  section(3, 16, 8),
                ],
              ),
            ),

            /// ANIMASI MENANG
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
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(19);

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
