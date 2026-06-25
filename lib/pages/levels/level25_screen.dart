import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../widgets/keyboard_number.dart';
import '../db/db_hive.dart';

class Level25Screen extends StatefulWidget {
  const Level25Screen({super.key});

  @override
  State<Level25Screen> createState() => _Level25ScreenState();
}

class _Level25ScreenState extends State<Level25Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// GRID
  final List<List<int?>> grid = const [
    [1, 2, 3, null, 5],
    [6, null, 8, 9, 10],
    [11, 12, 13, null, 15],
    [null, 17, 18, 19, 20],
    [21, 22, 23, 24, null],
    [26, 27, 28, null, 30],
    [31, null, 33, 34, 35],
  ];

  /// POSISI NULL (urutan input)
  final List<Map<String, int>> inputCells = [
    {"row": 0, "col": 3},
    {"row": 1, "col": 1},
    {"row": 2, "col": 3},
    {"row": 3, "col": 0},
    {"row": 4, "col": 4},
    {"row": 5, "col": 3},
    {"row": 6, "col": 1},
  ];

  /// JAWABAN
  final List<int> answers = [4, 7, 14, 16, 25, 29, 32];

  List<String> userInputs = List.filled(7, '');
  List<bool> rowCorrect = List.filled(7, false);

  int activeRow = 0;

  bool showWin = false;
  bool hasWon = false;
  String? winAnimasi;

  String? lastCheckedStatus;

  /// MAX KARAKTER
  int maxChar(int row) {
    if (row <= 1) return 1;
    return 2;
  }

  /// =========================
  /// KEYBOARD INPUT
  /// =========================
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

      if (userInputs[activeRow].length < maxChar(activeRow)) {
        userInputs[activeRow] += key;

        if (userInputs[activeRow].length == maxChar(activeRow)) {
          if (activeRow < userInputs.length - 1) {
            activeRow++;
          }
        }
      }
    });

    autoCheckAnswers();
  }

  /// =========================
  /// AUTO CHECK
  /// =========================
  void autoCheckAnswers() async {
    for (int i = 0; i < userInputs.length; i++) {
      if (userInputs[i].length < maxChar(i)) return;
    }

    bool allCorrect = true;

    for (int i = 0; i < answers.length; i++) {
      bool ok = userInputs[i] == answers[i].toString();

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

  /// =========================
  /// RESULT DIALOG
  /// =========================
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

  /// =========================
  /// RESTART
  /// =========================
  void restart() {
    setState(() {
      userInputs = List.filled(7, '');

      rowCorrect = List.filled(7, false);

      activeRow = 0;

      lastCheckedStatus = null;

      showWin = false;

      hasWon = false;
    });
  }

  /// =========================
  /// WARNA ANGKA
  /// =========================
  Color getColor(int number) {
    switch (number) {
      case 1:
      case 13:
      case 21:
      case 28:
        return const Color(0xFF49B86E);

      case 2:
      case 23:
      case 31:
        return const Color(0xFFED8B4F);

      case 3:
      case 19:
      case 26:
        return const Color(0xFF6AAED6);

      case 5:
      case 12:
      case 24:
        return const Color(0xFF9E9E9E);

      case 6:
      case 18:
      case 33:
        return const Color(0xFFB24A16);

      case 8:
      case 11:
      case 15:
      case 30:
        return const Color(0xFF6C63A7);

      case 9:
      case 20:
      case 22:
      case 35:
        return const Color(0xFFEF3B39);

      case 10:
      case 17:
      case 27:
      case 34:
        return const Color(0xFFD16BA5);

      default:
        return Colors.white;
    }
  }

  /// =========================
  /// CELL BUILDER
  /// =========================
  Widget buildCell(int r, int c, int? number) {
    int index = inputCells.indexWhere((e) => e["row"] == r && e["col"] == c);

    /// INPUT CELL
    if (index != -1) {
      Color borderColor = Colors.black;

      if (lastCheckedStatus == null) {
        if (index == activeRow) {
          borderColor = Colors.blue;
        }
      } else {
        borderColor = rowCorrect[index] ? Colors.green : Colors.red;
      }

      return GestureDetector(
        onTap: () {
          if (lastCheckedStatus == null) {
            setState(() => activeRow = index);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            userInputs[index],
            style: TextStyle(
              fontSize: sp(20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    /// NORMAL CELL
    if (number == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: getColor(number),
        border: Border.all(color: Colors.black),
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: sp(20),
        ),
      ),
    );
  }

  /// =========================
  /// GRID
  /// =========================
  Widget buildGrid() {
    return Container(
      width: w(300),
      height: h(420),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: List.generate(grid.length, (r) {
          return Expanded(
            child: Row(
              children: List.generate(grid[r].length, (c) {
                return Expanded(
                  child: buildCell(r, c, grid[r][c]),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// =========================
  /// UI
  /// =========================
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
                      color: const Color(0xFFF79055),
                      alignment: Alignment.center,
                      child: Text(
                        'SEQUENCE',
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
                  "Isi angka yang tepat pada kotak yang kosong",
                  style: TextStyle(fontSize: sp(16)),
                ),

                SizedBox(height: h(30)),

                buildGrid(),

                const Spacer(),

                NumberKeyboard(
                  onKeyTap: handleKeyboard,
                ),
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
                    await DBHive.unlockNextLevel(25);

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
