import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level40Screen extends StatefulWidget {
  const Level40Screen({super.key});

  @override
  State<Level40Screen> createState() => _Level40ScreenState();
}

class _Level40ScreenState extends State<Level40Screen> {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// JAWABAN BENAR
  final Map<int, String> correctAnswers = {
    1: "SAYUR",
    2: "BUAH",
    3: "BULAT",
  };

  /// PILIHAN USER
  Map<int, String?> selectedAnswers = {
    1: null,
    2: null,
    3: null,
  };

  /// STATUS (correct / wrong)
  Map<int, String?> rowStatus = {
    1: null,
    2: null,
    3: null,
  };

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  bool get allAnswered => selectedAnswers.values.every((e) => e != null);

  void restartLevel() {
    setState(() {
      selectedAnswers.updateAll((key, value) => null);
      rowStatus.updateAll((key, value) => null);
      hasWon = false;
    });
  }

  void autoCheckAnswer() async {
    if (!allAnswered || hasWon) return;

    bool allCorrect = true;

    for (int i = 1; i <= 3; i++) {
      if (selectedAnswers[i] == correctAnswers[i]) {
        rowStatus[i] = 'correct';
      } else {
        rowStatus[i] = 'wrong';
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

  /// OPTION BUTTON
  Widget optionButton(int row, String text) {
    bool isSelected = selectedAnswers[row] == text;

    Color borderColor = Colors.transparent;

    if (rowStatus[row] == 'correct' && isSelected) {
      borderColor = Colors.green;
    }

    if (rowStatus[row] == 'wrong' && isSelected) {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswers[row] = text;
          rowStatus[row] = null;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          autoCheckAnswer,
        );
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(6)),
            margin: EdgeInsets.symmetric(vertical: h(4)),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(w(8)),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: sp(16),
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          /// ARROW
          if (isSelected)
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  "assets/images/arrow.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// GAMBAR ITEM
  Widget imageItem(String asset) {
    return Image.asset(
      asset,
      width: w(60),
      height: h(60),
      fit: BoxFit.contain,
    );
  }

  /// ROW
  Widget imageRowWithOption({
    required int rowIndex,
    required List<String> images,
    required List<String> options,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(20)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(30)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(w(14)),
        ),
        child: Row(
          children: [
            /// GAMBAR
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: images.map((img) => imageItem(img)).toList(),
              ),
            ),

            SizedBox(width: w(10)),

            /// OPTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  options.map((opt) => optionButton(rowIndex, opt)).toList(),
            )
          ],
        ),
      ),
    );
  }

  void _nextLevel() async {
    await DBHive.unlockNextLevel(40);
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
                /// HEADER
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFFFBDF64),
                      alignment: Alignment.center,
                      child: Text(
                        'VARIABLE',
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

                SizedBox(height: h(30)),

                Text(
                  "Lingkari pilihan yang berhubungan \n dengan gambar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(40)),

                /// ROW 1
                imageRowWithOption(
                  rowIndex: 1,
                  images: [
                    "assets/images/40/sayur1.png",
                    "assets/images/40/sayur2.png",
                    "assets/images/40/sayur3.png",
                  ],
                  options: ["BUAH", "SAYUR"],
                ),

                SizedBox(height: h(25)),

                /// ROW 2
                imageRowWithOption(
                  rowIndex: 2,
                  images: [
                    "assets/images/40/buah1.png",
                    "assets/images/40/buah2.png",
                    "assets/images/40/buah3.png",
                  ],
                  options: ["BUAH", "SAYUR"],
                ),

                SizedBox(height: h(25)),

                /// ROW 3
                imageRowWithOption(
                  rowIndex: 3,
                  images: [
                    "assets/images/40/bola1.png",
                    "assets/images/40/bola2.png",
                    "assets/images/40/bola3.png",
                  ],
                  options: ["BULAT", "KOTAK"],
                ),
              ],
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
                    await DBHive.unlockNextLevel(40);

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

