import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_number.dart';
import '../db/db_hive.dart';

class Level7Screen extends StatefulWidget {
  const Level7Screen({super.key});

  @override
  State<Level7Screen> createState() => _Level7ScreenState();
}

class _Level7ScreenState extends State<Level7Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// input tiap soal (3 soal x 3 bentuk)
  List<List<String>> userInputs = [
    ['', '', ''],
    ['', '', ''],
    ['', '', '']
  ];

  /// mapping jawaban
  final List<List<String>> correctAnswers = [
    ['1', '1', '4'],
    ['1', '1', '1'],
    ['2', '1', '1']
  ];

  List<bool> rowCorrect = [false, false, false];

  String? lastCheckedStatus;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  int activeRow = 0;
  int activeCol = 0;

  late AnimationController _controller;

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

  /// =========================
  /// RESULT DIALOG
  /// =========================

  Future<void> showResultDialog(bool isCorrect) async {
    setState(() {
      lastCheckedStatus = isCorrect ? "correct" : "wrong";

      if (isCorrect) {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      }
    });

    if (isCorrect) {
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

  /// =========================
  /// CHECK ANSWER
  /// =========================

  void autoCheckAnswers() async {
    for (var row in userInputs) {
      for (var col in row) {
        if (col.isEmpty) return;
      }
    }

    bool allCorrect = true;

    for (int r = 0; r < userInputs.length; r++) {
      bool correct = true;

      for (int c = 0; c < 3; c++) {
        if (userInputs[r][c] != correctAnswers[r][c]) {
          correct = false;
        }
      }

      rowCorrect[r] = correct;

      if (!correct) {
        allCorrect = false;
      }
    }

    setState(() {});

    if (allCorrect) {
      hasWon = true;
      await showResultDialog(true);
      setState(() {});
    } else {
      await showResultDialog(false);
      restartLevel7Screen();
    }
  }

  /// =========================
  /// RESTART
  /// =========================

  void restartLevel7Screen() {
    setState(() {
      userInputs = [
        ['', '', ''],
        ['', '', ''],
        ['', '', '']
      ];

      rowCorrect = [false, false, false];

      lastCheckedStatus = null;
      hasWon = false;
      showWin = false;

      activeRow = 0;
      activeCol = 0;
    });
  }

  /// =========================
  /// KEYBOARD INPUT
  /// =========================

  void handleInput(String key) {
    setState(() {
      if (key == '←') {
        if (userInputs[activeRow][activeCol].isNotEmpty) {
          userInputs[activeRow][activeCol] = '';
        } else {
          if (activeCol > 0) {
            activeCol--;

            userInputs[activeRow][activeCol] = '';
          }
        }

        return;
      }

      if (userInputs[activeRow][activeCol].isEmpty) {
        userInputs[activeRow][activeCol] = key;

        if (activeCol < 2) {
          activeCol++;
        } else {
          if (activeRow < 2) {
            activeRow++;
            activeCol = 0;
          }
        }
      }
    });

    autoCheckAnswers();
  }

  void _nextLevel7Screen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level7Screen 8 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// =========================
  /// SHAPES
  /// =========================

  Widget circleShape() {
    return Container(
      width: w(35),
      height: h(35),
      decoration:
          const BoxDecoration(color: Color(0xff3C3C3C), shape: BoxShape.circle),
    );
  }

  Widget squareShape() {
    return Container(
      width: w(35),
      height: h(35),
      color: const Color(0xff3C3C3C),
    );
  }

  Widget triangleShape() {
    return CustomPaint(
      size: Size(w(35), h(35)),
      painter: TrianglePainter(),
    );
  }

  /// =========================
  /// ANSWER BOX
  /// =========================

  Widget answerBox(int row, int col) {
    Color borderColor = Colors.black;
    double borderWidth = 1.5;

    // aktif = biru (hanya sebelum dicek)
    if (lastCheckedStatus == null &&
        row == activeRow &&
        col == activeCol) {
      borderColor = Colors.blue;
      borderWidth = 2.5;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          activeRow = row;
          activeCol = col;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: w(40),
        height: h(35),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white, // selalu putih
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(w(6)), // optional
        ),
        child: Text(
          userInputs[row][col],
          style: TextStyle(
            fontSize: sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// ROW SOAL
  /// =========================

  Widget questionItem(String imagePath, int row) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: w(130),
            height: h(130),
          ),
          SizedBox(width: w(30)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  circleShape(),
                  SizedBox(width: w(10)),
                  const Text("="),
                  SizedBox(width: w(10)),
                  answerBox(row, 0)
                ],
              ),
              SizedBox(height: h(10)),
              Row(
                children: [
                  squareShape(),
                  SizedBox(width: w(10)),
                  const Text("="),
                  SizedBox(width: w(10)),
                  answerBox(row, 1)
                ],
              ),
              SizedBox(height: h(10)),
              Row(
                children: [
                  triangleShape(),
                  SizedBox(width: w(10)),
                  const Text("="),
                  SizedBox(width: w(10)),
                  answerBox(row, 2)
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  /// =========================
  /// BUILD
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
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFFEE3E3E),
                      alignment: Alignment.center,
                      child: Text(
                        'DECOMPOSITION',
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
                SizedBox(height: h(18)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(20)),
                  child: Text(
                    'Hitung jumlah bentuk pada gambar disampingnya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: sp(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: h(40)),
                    child: Column(
                      children: [
                        questionItem("assets/images/7/7_1.png", 0),
                        questionItem("assets/images/7/7_2.png", 1),
                        questionItem("assets/images/7/7_3.png", 2),
                      ],
                    ),
                  ),
                ),
                NumberKeyboard(onKeyTap: handleInput),
              ],
            ),
            if (showWin && winAnimasi != null)
              Center(
                child: Lottie.asset(
                  winAnimasi!,
                  width: w(250),
                  height: w(250),
                  repeat: false,
                ),
              )
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
                    await DBHive.unlockNextLevel(7);

                    _nextLevel7Screen();

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

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff3C3C3C)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
