import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_letter.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level14Screen extends StatefulWidget {
  const Level14Screen({super.key});

  @override
  State<Level14Screen> createState() => _Level14ScreenState();
}

class _Level14ScreenState extends State<Level14Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// MATRIX
  final List<List<dynamic>> gridData = const [
    ["W", "A", "G", "N", "I", "P", "M", "U"],
    ["E", "T", Colors.orange, "A", "I", "A", "R", "A"],
    ["F", "J", "L", "O", "R", Colors.pink, "A", "K"],
    ["G", "I", "D", Colors.red, "Z", "U", "H", "A"],
    ["U", "A", "B", "U", "R", "A", Colors.purple, "B"],
    ["I", Colors.green, "N", "A", "S", "T", "M", "O"],
    ["D", "U", "Y", "R", Colors.blue, "K", "A", "S"],
    ["A", "K", "I", "C", "E", "P", "I", "S"],
  ];

  /// JAWABAN BENAR
  final Map<int, String> correctAnswers = {
    0: "DIA",
    1: "KAS",
    2: "BAK",
    3: "ABU",
    4: "AIR",
    5: "API",
  };

  /// CONTROLLER
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  int activeCard = 0;

  /// ANIMATION
  late AnimationController _controller;

  String? lastCheckedStatus;
  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// CEK SEMUA TERISI
  bool get allFilled {
    for (var c in controllers) {
      if (c.text.length != 3) return false;
    }
    return true;
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

  /// PILIH CARD
  void selectCard(int index) {
    setState(() {
      activeCard = index;
    });
  }

  /// HANDLE KEYBOARD
  void handleKeyTap(String key) {
    setState(() {
      var controller = controllers[activeCard];
      String text = controller.text;

      /// DELETE
      if (key == '←') {
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

      /// BATAS 3 HURUF
      if (text.length < 3) {
        controller.text += key;
      }

      /// PINDAH CARD OTOMATIS
      if (controller.text.length == 3 && activeCard < controllers.length - 1) {
        activeCard++;
      }
    });

    Future.delayed(const Duration(milliseconds: 200), autoCheckAnswers);
  }

  /// AUTO CHECK
  void autoCheckAnswers() async {
    if (!allFilled || hasWon) return;

    bool allCorrect = true;

    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.toUpperCase() != correctAnswers[i]) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() {
        lastCheckedStatus = "correct";
        hasWon = true;

        activeCard = -1; // 🔥 NONAKTIFKAN SEMUA
      });

      _controller.forward(from: 0);

      await showResultDialog(true);
    } else {
        setState(() {
          lastCheckedStatus = "wrong";

          activeCard = -1; // 🔥 NONAKTIFKAN SEMUA
        });

      _controller.forward(from: 0);

      await showResultDialog(false);

      restartLevel();
    }
  }

  /// ANIMASI HASIL
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
    DBHive.unlockNextLevel(14);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Level 15 terbuka!")),
    );

    Navigator.pop(context);
  }

  /// CARD
  Widget buildStartCard({
    required int index,
    required String title,
    required Color color,
    required List<String> images,
  }) {
    bool isActive = activeCard == index;

    Color borderColor = Colors.black;
    bool isCheckingDone = lastCheckedStatus != null;

    return InkWell(
      onTap: () {
        selectCard(index);
      },
      child: Container(
        padding: EdgeInsets.all(w(3)),
        decoration: BoxDecoration(
          color: color,


          border: Border.all(
            color: (!isCheckingDone && isActive)
                ? Colors.blue
                : borderColor,
            width: (!isCheckingDone && isActive) ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(w(10)),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: sp(10),
              ),
            ),
            SizedBox(height: h(3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((img) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(3)),
                  child: Image.asset(
                    img,
                    width: w(15),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: h(3)),
            Container(
              width: w(50),
              height: h(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(w(5)),
              ),
              child: TextField(
                controller: controllers[index],
                readOnly: true,
                textAlign: TextAlign.center,
                maxLength: 3,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sp(10),
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            )
          ],
        ),
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

                Padding(
                  padding: EdgeInsets.all(w(10)),
                  child: Text(
                    'Temukan kata tersembunyi \n dengan mengikuti panah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                /// GRID
                Center(
                  child: Container(
                    width: w(290),
                    height: h(290),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: List.generate(8, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(8, (col) {
                              var cell = gridData[row][col];

                              return Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: cell is Color ? cell : Colors.white,
                                    border: Border(
                                      right: BorderSide(
                                          color: col != 7
                                              ? Colors.black
                                              : Colors.transparent),
                                      bottom: BorderSide(
                                          color: row != 7
                                              ? Colors.black
                                              : Colors.transparent),
                                    ),
                                  ),
                                  child: cell is String
                                      ? Text(
                                          cell,
                                          style: TextStyle(
                                            fontSize: sp(18),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// CARD
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(20)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildStartCard(
                              index: 0,
                              title: "START MERAH",
                              color: Colors.red,
                              images: [
                                "assets/images/panah_kiri_m.png",
                                "assets/images/panah_kiri_m.png",
                                "assets/images/panah_bawah_m.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildStartCard(
                              index: 1,
                              title: "START BIRU",
                              color: Colors.blue,
                              images: [
                                "assets/images/panah_kanan_b.png",
                                "assets/images/panah_kanan_b.png",
                                "assets/images/panah_kanan_b.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildStartCard(
                              index: 2,
                              title: "START UNGU",
                              color: Colors.purple,
                              images: [
                                "assets/images/panah_kanan_u.png",
                                "assets/images/panah_atas_u.png",
                                "assets/images/panah_atas_u.png",
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h(10)),
                      Row(
                        children: [
                          Expanded(
                            child: buildStartCard(
                              index: 3,
                              title: "START HIJAU",
                              color: Colors.green,
                              images: [
                                "assets/images/panah_atas_h.png",
                                "assets/images/panah_kanan_h.png",
                                "assets/images/panah_kanan_h.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildStartCard(
                              index: 4,
                              title: "START OREN",
                              color: Colors.orange,
                              images: [
                                "assets/images/panah_kanan_o.png",
                                "assets/images/panah_kanan_o.png",
                                "assets/images/panah_bawah_o.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildStartCard(
                              index: 5,
                              title: "START PINK",
                              color: Colors.pink,
                              images: [
                                "assets/images/panah_atas_p.png",
                                "assets/images/panah_atas_p.png",
                                "assets/images/panah_kiri_p.png",
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
                    await DBHive.unlockNextLevel(14);

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
