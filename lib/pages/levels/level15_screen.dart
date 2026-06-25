import 'package:flutter/material.dart';
import '../widgets/keyboard_koordinat.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level15Screen extends StatefulWidget {
  const Level15Screen({super.key});

  @override
  State<Level15Screen> createState() => _Level15ScreenState();
}

class _Level15ScreenState extends State<Level15Screen> {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// INPUT USER (5 kotak)
  List<String> userInputs = List.filled(5, '');

  /// STATUS WARNA
  List<bool> isCorrect = List.filled(5, false);
  String? lastStatus;

  int activeIndex = 0;

  /// MATRIX 5x5
  final List<List<String?>> gridData = const [
    [null, null, null, null, "assets/images/orang.jpg"],
    [
      null,
      "assets/images/pohon.jpg",
      null,
      "assets/images/pohon.jpg",
      "assets/images/pohon.jpg"
    ],
    [
      "assets/images/rumah.jpg",
      "assets/images/pohon.jpg",
      null,
      "assets/images/buaya.jpg",
      "assets/images/pohon.jpg"
    ],
    [
      "assets/images/pohon.jpg",
      "assets/images/pohon.jpg",
      null,
      "assets/images/pohon.jpg",
      "assets/images/pohon.jpg"
    ],
    ["assets/images/snake.png", null, null, null, "assets/images/singa.jpg"],
  ];

  final List<String> rowLabels = const ["A", "B", "C", "D", "E"];
  final List<String> colLabels = const ["1", "2", "3", "4", "5"];

  bool hasChecked = false;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  @override
  void initState() {
    super.initState();
    activeIndex = 0;
  }

  /// HANDLE INPUT
  void handleInput(String key) {
    setState(() {
      if (key == '←') {
        if (userInputs[activeIndex].isNotEmpty) {
          userInputs[activeIndex] = '';
        }
        return;
      }

      if (userInputs[activeIndex].length < 2) {
        userInputs[activeIndex] += key.toUpperCase();

        /// kalau sudah 2 karakter → pindah otomatis
        if (userInputs[activeIndex].length == 2) {
          if (activeIndex < 4) {
            activeIndex++;
          }
        }
      }
    });

    autoCheckAnswer();
  }

  void autoCheckAnswer() async {
    /// cek semua sudah 2 karakter
    bool allFilled = userInputs.every((e) => e.length == 2);
    if (!allFilled) return;

    hasChecked = true;

    /// reset dulu
    List<bool> tempCorrect = List.filled(5, false);

    /// =========================
    /// INDEX 1 dan 3 (FIXED)
    /// =========================
    if (userInputs[1] == "B1") tempCorrect[1] = true;
    if (userInputs[3] == "A1") tempCorrect[3] = true;

    /// =========================
    /// INDEX 0,2,4 (UNIK)
    /// =========================
    List<int> specialIndex = [0, 2, 4];
    List<String> validSet = ["A2", "A3", "A4"];

    Map<String, int> used = {};

    for (int i in specialIndex) {
      String val = userInputs[i];

      if (validSet.contains(val)) {
        if (!used.containsKey(val)) {
          used[val] = i;
          tempCorrect[i] = true;
        } else {
          /// duplikat → salah
          tempCorrect[i] = false;
        }
      }
    }

    setState(() {
      isCorrect = tempCorrect;
      lastStatus = "checked";

      // 🔥 NONAKTIFKAN semua fokus
      activeIndex = -1;
    });

    /// =========================
    /// CEK MENANG / SALAH
    /// =========================
    bool allCorrect = tempCorrect.every((e) => e);

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
      /// ada yang salah → bunyi salah
      await AudioManager().playEffect('sounds/salah.mp3');

      /// delay biar warna merah keliatan
      await Future.delayed(const Duration(seconds: 2));

      restartKeepCorrect();
    }
  }

  void restartKeepCorrect() {
    setState(() {
      for (int i = 0; i < userInputs.length; i++) {
        if (!isCorrect[i]) {
          userInputs[i] = '';
        }
      }

      /// reset index ke pertama yg kosong
      activeIndex = userInputs.indexWhere((e) => e.isEmpty);
      if (activeIndex == -1) activeIndex = 0;
    });
  }

  Widget inputBox(int index) {
    bool isActive = index == activeIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          activeIndex = index;
        });
      },
      child: SizedBox(
        width: w(40),
        height: h(40),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.blue : Colors.black,
                width: 2,
              ),
            ),
          ),
          child: Text(
            userInputs[index],
            style: TextStyle(
              fontSize: sp(18),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// ITEM (gambar + input)
  Widget item(String image, int index) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Image.asset(
            image,
            width: w(50),
            height: h(50),
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: h(5)),
        inputBox(index),
      ],
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

                SizedBox(height: h(10)),
                Padding(
                  padding: EdgeInsets.all(w(10)),
                  child: Text(
                    'Tulis koordinat yang sesuai agar sampai ke rumah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: h(10)),

                /// GRID + LABEL
                Center(
                  child: Column(
                    children: [
                      /// ANGKA
                      Row(
                        children: [
                          SizedBox(width: w(30)),
                          ...List.generate(5, (index) {
                            return SizedBox(
                              width: w(60),
                              child: Center(
                                child: Text(
                                  colLabels[index],
                                  style: TextStyle(
                                    fontSize: sp(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                      SizedBox(height: h(5)),

                      /// GRID
                      Row(
                        children: [
                          Column(
                            children: List.generate(5, (row) {
                              return SizedBox(
                                height: h(60),
                                width: w(30),
                                child: Center(
                                  child: Text(
                                    rowLabels[row],
                                    style: TextStyle(
                                      fontSize: sp(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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
                              children: List.generate(5, (row) {
                                return Expanded(
                                  child: Row(
                                    children: List.generate(5, (col) {
                                      String? imagePath = gridData[row][col];

                                      return Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: col != 4
                                                    ? Colors.black
                                                    : Colors.transparent,
                                              ),
                                              bottom: BorderSide(
                                                color: row != 4
                                                    ? Colors.black
                                                    : Colors.transparent,
                                              ),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: imagePath != null
                                              ? Image.asset(imagePath)
                                              : const SizedBox(),
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

                SizedBox(height: h(30)),

                /// 🔥 ROW ITEM (INI YANG KAMU MAU)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    item("assets/images/15/15a.png", 0),
                    SizedBox(width: w(8)),
                    item("assets/images/15/15b.png", 1),
                    SizedBox(width: w(8)),
                    item("assets/images/15/15a.png", 2),
                    SizedBox(width: w(8)),
                    item("assets/images/15/15c.png", 3),
                    SizedBox(width: w(8)),
                    item("assets/images/15/15a.png", 4),
                  ],
                ),

                const Spacer(),

                /// KEYBOARD
                KeyboardKoordinat(onKeyTap: handleInput),
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
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(15);

                    // _nextLevel();

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
