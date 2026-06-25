import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level18Screen extends StatefulWidget {
  const Level18Screen({super.key});

  @override
  State<Level18Screen> createState() => _Level18ScreenState();
}

class _Level18ScreenState extends State<Level18Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  static const String imagePath = "assets/images/18/18.png";

  Color selectedColor = Colors.red;

  late List<List<Color?>> grids;
  late List<List<bool>> isEditable;

  /// ================= MAPPING JAWABAN =================
  final List<List<Color>> correctPairs = [
    [Colors.green, Colors.red], // row 1
    [Colors.blue, Colors.yellow], // row 2
    [Colors.pink, Colors.purple], // row 3
    [Colors.red], // row 4
    [Colors.pink], // row 5
  ];

  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;

  /// ================= INIT =================
  void initGameData() {
    grids = [
      [Colors.green, Colors.red, Colors.green, Colors.red, null, null],
      [Colors.yellow, null, null, Colors.blue, Colors.yellow, Colors.blue],
      [null, null, Colors.pink, Colors.purple, Colors.pink, Colors.purple],
      [
        Colors.yellow,
        Colors.green,
        Colors.red,
        Colors.yellow,
        Colors.green,
        null
      ],
      [
        Colors.blue,
        Colors.pink,
        Colors.purple,
        Colors.blue,
        null,
        Colors.purple
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
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
      initGameData();
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

      setState(() => showWin = false);
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
        hasWon = true;
      });

      _controller.forward(from: 0);
      await showResultDialog(true);
    } else {

      _controller.forward(from: 0);
      await showResultDialog(false);
    }
  }


  /// ================= CIRCLE ITEM =================
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
      child: Container(
        width: w(40),
        height: h(40),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? Colors.transparent,
          border: Border.all(
            color: Colors.black,
            width: 1.5, // 🔥 samakan dengan UI contoh
          ),
        ),
      ),
    );
  }

  Widget buildCircleRow(int rowIndex) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        6,
        (index) => circleItem(rowIndex, index),
      ),
    );
  }

  /// ================= IMAGE =================
  Widget imageItem() {
    return SizedBox(
      width: w(55),
      height: h(55),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget rowCircleThenImage(int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildCircleRow(rowIndex),
        imageItem(),
      ],
    );
  }

  Widget rowImageThenCircle(int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        imageItem(),
        buildCircleRow(rowIndex),
      ],
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
      const SnackBar(content: Text('Level 19 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// ================= UI =================
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

                SizedBox(height: h(30)),

                rowCircleThenImage(0),
                SizedBox(height: h(20)),

                rowImageThenCircle(1),
                SizedBox(height: h(20)),

                rowCircleThenImage(2),
                SizedBox(height: h(20)),

                rowImageThenCircle(3),
                SizedBox(height: h(20)),

                rowCircleThenImage(4),

                const Spacer(),

                /// COLOR PICKER
                Container(
                  height: h(80),
                  color: const Color(0xFFF7F7F7),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        colorPicker(Colors.red),
                        SizedBox(width: w(10)),
                        colorPicker(Colors.green),
                        SizedBox(width: w(10)),
                        colorPicker(Colors.yellow),
                        SizedBox(width: w(10)),
                        colorPicker(Colors.blue),
                        SizedBox(width: w(10)),
                        colorPicker(Colors.pink),
                        SizedBox(width: w(10)),
                        colorPicker(Colors.purple),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// WIN ANIMATION
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
                    await DBHive.unlockNextLevel(18);

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
