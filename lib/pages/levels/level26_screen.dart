import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level26Screen extends StatefulWidget {
  const Level26Screen({super.key});

  @override
  State<Level26Screen> createState() => _Level26ScreenState();
}

class _Level26ScreenState extends State<Level26Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  final Map<int, String> correctAnswers = {
    1: "KENYANG",
    2: "GIGI SEHAT",
    3: "BADAN BUGAR",
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

  Widget leftItem(String image, String text) {
    return Column(
      children: [
        Image.asset(image, width: w(80), height: h(80)),
        SizedBox(height: h(6)),
        Text(
          text,
          style: TextStyle(fontSize: sp(13), letterSpacing: 1),
        )
      ],
    );
  }

  Widget rightChoice(int index, String image, String text) {
    bool isSelected = selected[index] == text;
    bool isCorrect = correctAnswers[index] == text;

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
          if (selected[index] == text) {
            selected[index] = null;
          } else {
            selected[index] = text;
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
                  borderRadius: BorderRadius.circular(w(10)),
                ),
                child: Image.asset(
                  image,
                  width: w(75),
                  height: h(75),
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
            text,
            style: TextStyle(
              fontSize: sp(13),
              letterSpacing: 1,
            ),
          )
        ],
      ),
    );
  }

  Widget rowItem({
    required int index,
    required String leftImg,
    required String leftText,
    required String right1Img,
    required String right1Text,
    required String right2Img,
    required String right2Text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h(20)),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: leftItem(leftImg, leftText),
            ),
          ),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                rightChoice(index, right1Img, right1Text),
                rightChoice(index, right2Img, right2Text),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _nextLevel() async {
    await DBHive.unlockNextLevel(26);

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            double lineX = constraints.maxWidth * 0.4;
            double topLine = h(125);
            double upperHeight = h(50);

            return Stack(
              children: [
                Column(
                  children: [
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
                    SizedBox(height: h(20)),
                    Text(
                      "Lingkari kondisi yang tepat",
                      style: TextStyle(fontSize: sp(18)),
                    ),
                    SizedBox(height: h(20)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: h(30)),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              "JIKA",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: sp(18),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Text(
                              "MAKA",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: sp(18),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h(10)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: w(30)),
                      child: Container(
                        height: h(1.5),
                        color: Colors.black54,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: w(20)),
                        children: [
                          rowItem(
                            index: 1,
                            leftImg: "assets/images/26/makan.png",
                            leftText: "MAKAN",
                            right1Img: "assets/images/26/kenyang.png",
                            right1Text: "KENYANG",
                            right2Img: "assets/images/26/lapar.png",
                            right2Text: "LAPAR",
                          ),
                          rowItem(
                            index: 2,
                            leftImg: "assets/images/26/sikat_gigi.png",
                            leftText: "SIKAT GIGI",
                            right1Img: "assets/images/26/gigi_sehat.png",
                            right1Text: "GIGI SEHAT",
                            right2Img: "assets/images/26/gigi_sakit.png",
                            right2Text: "GIGI SAKIT",
                          ),
                          rowItem(
                            index: 3,
                            leftImg: "assets/images/26/tidur.png",
                            leftText: "TIDUR CUKUP",
                            right1Img: "assets/images/26/ngantuk.png",
                            right1Text: "NGANTUK",
                            right2Img: "assets/images/26/badan_bugar.png",
                            right2Text: "BADAN BUGAR",
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: topLine,
                  left: lineX,
                  child: Container(
                    width: w(1.5),
                    height: upperHeight,
                    color: Colors.black54,
                  ),
                ),
                Positioned(
                  top: topLine + upperHeight,
                  left: lineX,
                  bottom: h(150),
                  child: Container(
                    width: w(1.5),
                    color: Colors.black54,
                  ),
                ),
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
            );
          },
        ),
      ),
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(26);

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
