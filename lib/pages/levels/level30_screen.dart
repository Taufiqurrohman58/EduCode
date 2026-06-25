import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level30Screen extends StatefulWidget {
  const Level30Screen({super.key});

  @override
  State<Level30Screen> createState() => _Level30ScreenState();
}

class _Level30ScreenState extends State<Level30Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// JAWABAN BENAR
  final Map<int, String> correctAnswers = {
    1: "Cucian basah",
    2: "Nilai ujian jelek",
    3: "Tersandung",
  };

  Map<int, String?> selected = {
    1: null,
    2: null,
    3: null,
  };

  Map<int, String?> questionStatus = {
    1: null,
    2: null,
    3: null,
  };

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  bool get allAnswered => selected.values.every((e) => e != null);

  void restartLevel() {
    setState(() {
      selected = {1: null, 2: null, 3: null};
      questionStatus = {1: null, 2: null, 3: null};
      hasWon = false;
    });
  }

  void autoCheckAnswers() async {
    if (!allAnswered || hasWon) return;

    bool allCorrect = true;

    for (int i = 1; i <= 3; i++) {
      if (selected[i] == correctAnswers[i]) {
        questionStatus[i] = 'correct';
      } else {
        questionStatus[i] = 'wrong';
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

  /// OPTION
  Widget conditionOption({
    required int index,
    required String image,
    required String label,
  }) {
    bool isSelected = selected[index] == label;
    bool isCorrect = correctAnswers[index] == label;

    Color borderColor = Colors.transparent;

    if (isSelected && questionStatus[index] == 'correct') {
      borderColor = Colors.green;
    }

    if (isSelected && questionStatus[index] == 'wrong') {
      borderColor = isCorrect ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected[index] == label) {
            selected[index] = null;
          } else {
            selected[index] = label;
          }

          questionStatus[index] = null;
        });

        Future.delayed(const Duration(milliseconds: 300), autoCheckAnswers);
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 3),
                  borderRadius: BorderRadius.circular(w(12)),
                ),
                child: Image.asset(
                  image,
                  width: w(80),
                  height: h(80),
                ),
              ),
              if (isSelected)
                Image.asset(
                  "assets/images/arrow.png",
                  width: w(80),
                  height: h(80),
                ),
            ],
          ),
          SizedBox(height: h(6)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sp(14),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget optionRow(List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(top: h(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }

  Widget conditionBlock({
    required int index,
    required String question,
    required List<Widget> options,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h(14)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: w(20)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question,
                style: TextStyle(fontSize: sp(16)),
              ),
            ),
          ),
          SizedBox(height: h(10)),
          optionRow(options),
        ],
      ),
    );
  }

  

  void _nextLevel() async {
    await DBHive.unlockNextLevel(30);

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
                      color: const Color(0xFFE27AAF),
                      alignment: Alignment.center,
                      child: Text(
                        'CONDITION',
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
                  "Lingkari kondisi yang sesuai",
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(10)),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w(14)),
                      child: Column(
                        children: [
                          conditionBlock(
                            index: 1,
                            question: "Jika hujan, maka:",
                            options: [
                              conditionOption(
                                index: 1,
                                image: "assets/images/30/cucian_basah.png",
                                label: "Cucian basah",
                              ),
                              conditionOption(
                                index: 1,
                                image: "assets/images/30/lapar.png",
                                label: "Lapar",
                              ),
                              conditionOption(
                                index: 1,
                                image: "assets/images/30/haus.png",
                                label: "Haus",
                              ),
                            ],
                          ),
                          conditionBlock(
                            index: 2,
                            question: "Jika tidak belajar, maka:",
                            options: [
                              conditionOption(
                                index: 2,
                                image: "assets/images/30/kotor.png",
                                label: "Kotor",
                              ),
                              conditionOption(
                                index: 2,
                                image: "assets/images/30/nilai_ujian_jelek.png",
                                label: "Nilai ujian jelek",
                              ),
                              conditionOption(
                                index: 2,
                                image: "assets/images/30/tidur.png",
                                label: "Tidur",
                              ),
                            ],
                          ),
                          conditionBlock(
                            index: 3,
                            question: "Jika berjalan tidak hati-hati, maka:",
                            options: [
                              conditionOption(
                                index: 3,
                                image: "assets/images/30/kesandung.png",
                                label: "Tersandung",
                              ),
                              conditionOption(
                                index: 3,
                                image: "assets/images/30/ngantuk.png",
                                label: "Ngantuk",
                              ),
                              conditionOption(
                                index: 3,
                                image: "assets/images/30/gatal.png",
                                label: "Gatal",
                              ),
                            ],
                          ),
                          SizedBox(height: h(40)),
                        ],
                      ),
                    ),
                  ),
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
                    await DBHive.unlockNextLevel(30);

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
