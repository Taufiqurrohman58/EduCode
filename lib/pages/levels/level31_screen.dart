import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level31Screen extends StatefulWidget {
  const Level31Screen({super.key});

  @override
  State<Level31Screen> createState() => _Level31ScreenState();
}

class _Level31ScreenState extends State<Level31Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// =============================
  /// DATA GRID (TETAP)
  /// =============================
  final List<List<String?>> gridData = const [
    [
      "assets/images/31/orang.jpg",
      "assets/images/31/jalan_a.png",
      "assets/images/31/jalan_c.png",
      "assets/images/31/pohon.jpg",
    ],
    [
      "assets/images/31/pohon.jpg",
      "assets/images/31/pohon.jpg",
      "assets/images/31/jalan_b.png",
      "assets/images/31/jalan_c.png",
    ],
    [
      "assets/images/31/pohon.jpg",
      "assets/images/31/gajah.png",
      "assets/images/31/pohon.jpg",
      "assets/images/31/jalan_b.png",
    ],
    [
      "assets/images/31/pohon.jpg",
      "assets/images/31/pohon.jpg",
      "assets/images/31/pohon.jpg",
      "assets/images/31/rumah.jpg",
    ],
  ];

  final List<String> rowLabels = const ["A", "B", "C", "D"];
  final List<String> colLabels = const ["1", "2", "3", "4"];

  /// =============================
  /// JAWABAN
  /// =============================
  final List<String> textOptions = ["A2", "C1", "B3"];
  final List<String> imageOptions = [
    "assets/images/31/jalan_d.png",
    "assets/images/31/jalan_e.png",
    "assets/images/31/jalan_a.png",
  ];

  final String correctText = "B3";
  final String correctImage = "assets/images/31/jalan_d.png";

  String? selectedText;
  String? selectedImage;

  Map<String, String?> textStatus = {};
  Map<String, String?> imageStatus = {};

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  bool get allSelected => selectedText != null && selectedImage != null;

  /// =============================
  /// RESET
  /// =============================
  void restartLevel() {
    setState(() {
      selectedText = null;
      selectedImage = null;
      textStatus.clear();
      imageStatus.clear();
      hasWon = false;
    });
  }

  /// =============================
  /// AUTO CHECK
  /// =============================
  void autoCheckAnswer() async {
    if (!allSelected || hasWon) return;

    bool allCorrect = true;

    /// TEXT CHECK
    for (var text in textOptions) {
      if (text == selectedText && text == correctText) {
        textStatus[text] = 'correct';
      } else if (text == selectedText) {
        textStatus[text] = 'wrong';
        allCorrect = false;
      }
    }

    /// IMAGE CHECK
    for (var img in imageOptions) {
      if (img == selectedImage && img == correctImage) {
        imageStatus[img] = 'correct';
      } else if (img == selectedImage) {
        imageStatus[img] = 'wrong';
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

  /// =============================
  /// WIDGET TEXT
  /// =============================
  Widget textItem(String text) {
    bool isSelected = selectedText == text;

    Color borderColor = Colors.transparent;

    if (isSelected && textStatus[text] == 'correct') {
      borderColor = Colors.green;
    } else if (isSelected && textStatus[text] == 'wrong') {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedText = text;
          textStatus[text] = null;
        });

        Future.delayed(const Duration(milliseconds: 300), autoCheckAnswer);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: w(45),
            height: h(45),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(w(8)),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: sp(18)),
            ),
          ),
          if (isSelected)
            Image.asset(
              "assets/images/arrow.png",
              width: w(40),
              height: h(40),
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }

  /// =============================
  /// WIDGET IMAGE
  /// =============================
  Widget imageItem(String path) {
    bool isSelected = selectedImage == path;

    Color borderColor = Colors.black;

    if (isSelected && imageStatus[path] == 'correct') {
      borderColor = Colors.green;
    } else if (isSelected && imageStatus[path] == 'wrong') {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImage = path;
          imageStatus[path] = null;
        });

        Future.delayed(const Duration(milliseconds: 300), autoCheckAnswer);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: w(70),
            height: h(70),
            margin: EdgeInsets.symmetric(horizontal: w(8)),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Image.asset(path, fit: BoxFit.cover),
          ),
          if (isSelected)
            Image.asset(
              "assets/images/arrow.png",
              width: w(70),
              height: h(70),
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }

  void _nextLevel() async {
    await DBHive.unlockNextLevel(31);
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
                      color: const Color(0xFFAC4616),
                      alignment: Alignment.center,
                      child: Text(
                        'DEBUGGING',
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

                /// ================= GRID =================
                Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: w(30)),
                          ...List.generate(4, (index) {
                            return SizedBox(
                              width: w(70),
                              child: Center(
                                child: Text(
                                  colLabels[index],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: h(5)),
                      Row(
                        children: [
                          Column(
                            children: List.generate(4, (row) {
                              return SizedBox(
                                height: h(70),
                                width: w(30),
                                child: Center(child: Text(rowLabels[row])),
                              );
                            }),
                          ),
                          Container(
                            width: w(300),
                            height: h(300),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              children: List.generate(4, (row) {
                                return Expanded(
                                  child: Row(
                                    children: List.generate(4, (col) {
                                      return Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            gridData[row][col]!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h(20)),

                /// ================= TEXT =================
                const Text("Lingkari jalan yang salah"),

                SizedBox(height: h(10)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: textOptions.map((e) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: w(16)),
                      child: textItem(e),
                    );
                  }).toList(),
                ),

                SizedBox(height: h(5)),

                /// ================= IMAGE =================
                const Text("Lingkari jalan yang seharusnya"),

                SizedBox(height: h(5)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageOptions.map((e) => imageItem(e)).toList(),
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
                    await DBHive.unlockNextLevel(31);

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
