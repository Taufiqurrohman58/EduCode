import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level16Screen extends StatefulWidget {
  const Level16Screen({super.key});

  @override
  State<Level16Screen> createState() => _Level16ScreenState();
}

class _Level16ScreenState extends State<Level16Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  Color selectedColor = Colors.red;

  late List<List<Color?>> grids;
  late List<List<bool>> isEditable;

  final List<List<Color>> correctPairs = [
    [Colors.green, Colors.red],
    [Colors.blue, Colors.yellow],
    [Colors.pink, Colors.orange],
    [const Color(0xFF8B4513), Colors.blue],
    [Colors.green, Colors.yellow],
    [const Color(0xFF8B4513), Colors.pink],
  ];

  String? lastCheckedStatus;
  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;

  /// ================= INIT DATA =================
  void initGameData() {
    grids = [
      [Colors.green, Colors.red, Colors.green, Colors.red, null, null],
      [Colors.yellow, Colors.blue, Colors.yellow, null, null, Colors.blue],
      [null, null, Colors.pink, Colors.orange, Colors.pink, Colors.orange],
      [
        null,
        Colors.blue,
        const Color(0xFF8B4513),
        Colors.blue,
        const Color(0xFF8B4513),
        null
      ],
      [Colors.green, Colors.yellow, null, Colors.yellow, Colors.green, null],
      [
        Colors.pink,
        null,
        null,
        const Color(0xFF8B4513),
        Colors.pink,
        const Color(0xFF8B4513)
      ],
    ];

    isEditable =
        grids.map((row) => row.map((c) => c == null).toList()).toList();
  }

  @override
  void initState() {
    super.initState();

    initGameData();

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

  /// ================= CHECK =================
  bool get allFilled {
    for (int r = 0; r < grids.length; r++) {
      for (int c = 0; c < grids[r].length; c++) {
        if (isEditable[r][c] && grids[r][c] == null) return false;
      }
    }
    return true;
  }

  /// ================= RESTART =================
  void restartLevel() {
    setState(() {
      initGameData(); // ✅ FIX: bukan initState()

      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  /// ================= RESULT =================
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
      restartLevel();
    }
  }

  /// ================= AUTO CHECK =================
  void autoCheckAnswers() async {
    if (!allFilled || hasWon) return;

    bool allCorrect = true;

    for (int r = 0; r < grids.length; r++) {
      final expected = correctPairs[r];

      for (int c = 0; c < grids[r].length; c++) {
        if (!isEditable[r][c]) continue;

        if (!expected.contains(grids[r][c])) {
          allCorrect = false;
        }
      }
    }

    if (allCorrect) {
      setState(() {
        lastCheckedStatus = 'correct';
        hasWon = true;
      });

      _controller.forward(from: 0);
      await showResultDialog(true);
    } else {
      setState(() => lastCheckedStatus = 'wrong');

      _controller.forward(from: 0);
      await showResultDialog(false);
    }
  }

  /// ================= BORDER =================
  Color getBorderColor(int row, int col) {
    final color = grids[row][col];

    // untuk yang bukan editable → tetap warna aslinya
    if (!isEditable[row][col]) {
      return color!;
    }

    // semua editable → selalu hitam
    return Colors.black;
  }

  /// ================= ITEM =================
  Widget circleItem(int row, int col) {
    final color = grids[row][col];

    return GestureDetector(
      onTap: isEditable[row][col]
          ? () {
              setState(() {
                grids[row][col] = selectedColor;
              });

              Future.delayed(
                  const Duration(milliseconds: 300), autoCheckAnswers);
            }
          : null,
      child: Center(
        child: Container(
          width: w(30),
          height: h(30),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? Colors.transparent,
            border: Border.all(
              color: getBorderColor(row, col),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  /// ================= GRID =================
  Widget buildRowGrid(int rowIndex) {
    return Container(
      width: w(300),
      height: h(50),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: (index != 5) ? Colors.black : Colors.transparent,
                ),
              ),
            ),
            child: circleItem(rowIndex, index),
          );
        },
      ),
    );
  }

  /// ================= COLOR PICKER =================
  Widget colorPicker(Color color) {
    bool isSelected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 45 : 40,
        height: isSelected ? 45 : 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.7),
                spreadRadius: 2,
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black,
              width: isSelected ? 4 : 2,
            ),
          ),
        ),
      ),
    );
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 17 berhasil terbuka!')),
    );
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
                SizedBox(height: h(30)),
                const Text("Warnai lingkaran sesuai pola"),
                SizedBox(height: h(25)),
                for (int i = 0; i < grids.length; i++) ...[
                  buildRowGrid(i),
                  SizedBox(height: h(20)),
                ],
                const Spacer(),
                Container(
                  height: h(80),
                  color: const Color(0xFFF7F7F7),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        colorPicker(Colors.red),
                        SizedBox(width: w(15)),
                        colorPicker(Colors.green),
                        SizedBox(width: w(15)),
                        colorPicker(Colors.yellow),
                        SizedBox(width: w(15)),
                        colorPicker(Colors.blue),
                        SizedBox(width: w(15)),
                        colorPicker(Colors.orange),
                        SizedBox(width: w(15)),
                        colorPicker(Colors.pink),
                        SizedBox(width: w(15)),
                        colorPicker(const Color(0xFF8B4513)),
                      ],
                    ),
                  ),
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
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(16);

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
