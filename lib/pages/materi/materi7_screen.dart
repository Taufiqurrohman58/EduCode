import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_number.dart';
import '../db/db_hive.dart';

class Materi7Screen extends StatefulWidget {
  const Materi7Screen({super.key});

  @override
  State<Materi7Screen> createState() => _Materi7ScreenState();
}

class _Materi7ScreenState extends State<Materi7Screen>
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
    ['2', '1', '1'],
    ['1', '1', '4'],
    ['1', '1', '1'],
  ];

  List<bool> rowCorrect = [false, false, false];

  String? lastCheckedStatus;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  int activeRow = 0;
  int activeCol = 0;

  final Map<String, GlobalKey> keyMap = {
  for (var k in ['1','2','3','4','5','6','7','8','9','0'])
    k: GlobalKey(),
};

final List<String> hintOrder = [
  '2','1','1',
  '1','1','4',
  '1','1','1',
];

int cursorIndex = 0;

late Animation<double> _bounceAnim;

  late AnimationController _controller;

@override
void initState() {
  super.initState();

  _controller = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );

  _bounceAnim = Tween<double>(
    begin: -6,
    end: 6,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  _controller.repeat(reverse: true);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) setState(() {});
  });
}
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Offset getKeyPosition(String key) {
  final context = keyMap[key]?.currentContext;

  if (context == null) return Offset.zero;

  final box = context.findRenderObject() as RenderBox;
  final position = box.localToGlobal(Offset.zero);

  return Offset(
    position.dx + box.size.width / 2 - w(5),
    position.dy - h(10),
  );
}

Widget buildKeyboardCursor() {
  if (cursorIndex >= hintOrder.length) {
    return const SizedBox();
  }

  String currentKey = hintOrder[cursorIndex];

  final pos = getKeyPosition(currentKey);

  if (pos == Offset.zero) {
    return const SizedBox();
  }

  return Positioned(
    top: pos.dy,
    left: pos.dx,
    child: AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: Image.asset(
            'assets/images/cursor.png',
            width: w(35),
          ),
        );
      },
    ),
  );
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
      restartMateri();
    }
  }

  /// =========================
  /// RESTART
  /// =========================

void restartMateri() {
  setState(() {
    userInputs = [
      ['', '', ''],
      ['', '', ''],
      ['', '', '']
    ];

    rowCorrect = [false, false, false];

    cursorIndex = 0;

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
      return;
    }

    if (cursorIndex >= hintOrder.length) return;

    String expectedKey = hintOrder[cursorIndex];

    // hanya boleh pencet angka yang ditunjuk cursor
    if (key != expectedKey) {
      return;
    }

    if (userInputs[activeRow][activeCol].isEmpty) {

      userInputs[activeRow][activeCol] = key;

      cursorIndex++;

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
  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi 8 berhasil terbuka!')),
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
                        questionItem("assets/images/7/7_3.png", 0),
                        questionItem("assets/images/7/7_1.png", 1),
                        questionItem("assets/images/7/7_2.png", 2),
                      ],
                    ),
                  ),
                ),
                NumberKeyboard(
  onKeyTap: handleInput,
  keyMap: keyMap,
),
              ],
            ),
            buildKeyboardCursor(),
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
                    await DBHive.completeMateri(7);

                    _nextMateri();

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
