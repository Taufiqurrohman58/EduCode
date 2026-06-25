import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_letter.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level12Screen extends StatefulWidget {
  const Level12Screen({super.key});

  @override
  State<Level12Screen> createState() => _Level12ScreenState();
}

class _Level12ScreenState extends State<Level12Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// MATRIX 5x5
  final List<List<String>> gridData = const [
    [
      "assets/images/12/kancil.jpg",
      "assets/images/12/ikan.jpg",
      "assets/images/12/ubur_ubur.jpg",
      "assets/images/12/koala.jpg",
      "assets/images/12/tupai.jpg",
    ],
    [
      "assets/images/12/zebra.jpg",
      "assets/images/12/harimau.jpg",
      "assets/images/12/badak.jpg",
      "assets/images/12/monyet.jpg",
      "assets/images/12/burung.jpg",
    ],
    [
      "assets/images/12/kuda_nil.jpg",
      "assets/images/12/ayam.jpg",
      "START",
      "assets/images/12/ular.jpg",
      "assets/images/12/jerapah.jpg",
    ],
    [
      "assets/images/12/kambing.jpg",
      "assets/images/12/unta.jpg",
      "assets/images/12/kuda.jpg",
      "assets/images/12/anjing.jpg",
      "assets/images/12/domba.jpg",
    ],
    [
      "assets/images/12/buaya.jpg",
      "assets/images/12/kucing.jpg",
      "assets/images/12/gajah.jpg",
      "assets/images/12/sapi.jpg",
      "assets/images/12/singa.jpg",
    ],
  ];

  /// CONTROLLER
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  /// PANJANG KATA
  final Map<int, int> answerLength = {
    0: 5,
    1: 6,
    2: 5,
    3: 5,
    4: 7,
    5: 4,
  };

  /// JAWABAN BENAR
  final Map<int, String> correctAnswers = {
    0: "DOMBA",
    1: "KUCING",
    2: "BADAK",
    3: "KOALA",
    4: "KAMBING",
    5: "AYAM",
  };

  int activeCard = 0;

  String? lastCheckedStatus;
  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  /// RESET LEVEL
  void restartLevel() {
    for (var c in controllers) {
      c.clear();
    }

    setState(() {
      activeCard = 0;
      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  /// CEK SEMUA TERISI
  bool get allFilled {
    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.length != answerLength[i]) {
        return false;
      }
    }
    return true;
  }

  /// PILIH CARD
  void selectCard(int index) {
    setState(() {
      activeCard = index;
    });
  }

  /// KEYBOARD
  void handleKeyTap(String key) {
    setState(() {
      var controller = controllers[activeCard];
      int maxLength = answerLength[activeCard]!;

      String text = controller.text;

      if (key == "←") {
        if (text.isNotEmpty) {
          controller.text = text.substring(0, text.length - 1);
        } else if (activeCard > 0) {
          activeCard--;

          var prev = controllers[activeCard];

          if (prev.text.isNotEmpty) {
            prev.text = prev.text.substring(0, prev.text.length - 1);
          }
        }

        return;
      }

      if (text.length < maxLength) {
        controller.text += key;
      }

      if (controller.text.length == maxLength &&
          activeCard < controllers.length - 1) {
        activeCard++;
      }
    });

    Future.delayed(const Duration(milliseconds: 200), autoCheckAnswers);
  }

  void autoCheckAnswers() async {
    if (!allFilled || hasWon) return;

    bool allCorrect = true;

    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.toUpperCase() != correctAnswers[i]) {
        allCorrect = false;
        break;
      }
    }

    // 🔥 TARUH DI SINI
    setState(() {
      lastCheckedStatus = allCorrect ? "correct" : "wrong";

      // ⛔ hilangkan semua fokus (tidak ada border biru lagi)
      activeCard = -1;
    });

    if (allCorrect) {
      hasWon = true;
      await showResultDialog(true);
    } else {
      await showResultDialog(false);
      restartLevel();
    }
  }

  /// ANIMASI
  Future<void> showResultDialog(bool isCorrect) async {
    if (isCorrect) {
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

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// NEXT LEVEL
  void _nextLevel() {
    DBHive.unlockNextLevel(12);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Level 13 terbuka!")),
    );

    Navigator.pop(context);
  }

    /// CARD
  Widget buildArrowCard({
    required int index,
    required List<String> arrows,
  }) {
    bool isActive = activeCard == index;

    Color borderColor = Colors.black;
    double borderWidth = 1;

    if (lastCheckedStatus == null && isActive) {
      borderColor = Colors.blue;
      borderWidth = 2;
    }

    return InkWell(
      onTap: () => selectCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: w(8), vertical: h(6)),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(w(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// PANAH
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: arrows.map((img) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(2)),
                  child: Image.asset(img, width: w(20)),
                );
              }).toList(),
            ),

            SizedBox(height: h(4)),

            /// 🔥 SLOT JAWABAN (GANTI PLACEHOLDER)
            buildAnswerRow(index),
          ],
        ),
      ),
    );
  }

  Widget buildAnswerRow(int index) {
    int maxLength = answerLength[index]!;
    String text = controllers[index].text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (i) {
        String char = i < text.length ? text[i] : "";

        return Container(
          width: w(9),
          height: h(18),
          margin: EdgeInsets.symmetric(horizontal: w(1.2)),
          alignment: Alignment.center, // ⬅️ ini kunci utama
          child: Column(
            mainAxisSize: MainAxisSize.min, // ⬅️ biar tidak full tinggi
            children: [
              Text(
                char,
                style: TextStyle(
                  fontSize: sp(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2), // jarak dikit biar enak
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black,
              ),
            ],
          ),
        );
      }),
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
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFF62B4E4),
                      alignment: Alignment.center,
                      child: Text(
                        'ALGORITHM',
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

                SizedBox(height: h(10)),
                Padding(
                  padding: EdgeInsets.all(w(10)),
                  child: Text(
                    'Tulis nama hewan sesuai anak panah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: h(10)),

                /// GRID
                Center(
                  child: Container(
                    width: w(300),
                    height: h(300),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: List.generate(5, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(5, (col) {
                              String value = gridData[row][col];

                              return Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                          color: col != 4
                                              ? Colors.black
                                              : Colors.transparent),
                                      bottom: BorderSide(
                                          color: row != 4
                                              ? Colors.black
                                              : Colors.transparent),
                                    ),
                                  ),
                                  child: value == "START"
                                      ? Container(
                                          color: Colors.red,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "START",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.all(w(10)), 
                                          child: Image.asset(
                                            value,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                SizedBox(height: h(15)),

                /// CARD
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(20)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildArrowCard(
                              index: 0,
                              arrows: [
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_bawah.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                              index: 1,
                              arrows: [
                                "assets/images/panah_bawah.png",
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_bawah.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                              index: 2,
                              arrows: [
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_atas.png",
                                "assets/images/panah_kiri.png",
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h(10)),
                      Row(
                        children: [
                          Expanded(
                            child: buildArrowCard(
                              index: 3,
                              arrows: [
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_atas.png",
                                "assets/images/panah_atas.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                              index: 4,
                              arrows: [
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_bawah.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                              index: 5,
                              arrows: [
                                "assets/images/panah_atas.png",
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_bawah.png",
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                LetterKeyboard(
                  onKeyTap: handleKeyTap,
                ),
              ],
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
                    await DBHive.unlockNextLevel(12);

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
