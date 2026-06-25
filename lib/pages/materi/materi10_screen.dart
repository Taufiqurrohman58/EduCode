import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi10Screen extends StatefulWidget {
  const Materi10Screen({super.key});

  @override
  State<Materi10Screen> createState() => _Materi10ScreenState();
}

class _Materi10ScreenState extends State<Materi10Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// MAPPING JAWABAN BENAR
  final Map<int, List<String>> correctMapping = {
    0: ["triangle", "horizontal"],
    1: ["diag2", "diag1"],
    2: ["circle", "vertical"],
    3: ["diag2", "horizontal"],
    4: ["diag1", "vertical"],
  };

  /// URUTAN PETUNJUK
int hintStep = 0;

/// urutan drag yang benar
final List<String> hintOrder = [
  "triangle",
  "horizontal",

  "diag2",
  "diag1",

  "circle",
  "vertical",

  "diag2",
  "horizontal",

  "diag1",
  "vertical",
];

/// target box setiap step
final List<int> targetOrder = [
  0,0,
  1,1,
  2,2,
  3,3,
  4,4,
];

late Animation<double> _cursorAnim;

  /// DROP DATA
  List<List<String>> answers = [
    [],
    [],
    [],
    [],
    [],
  ];

  late AnimationController _controller;

  bool showWin = false;
  bool hasWon = false;
  String? winAnimasi;

  String? lastCheckedStatus;

  

@override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  _cursorAnim = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  startCursorAnimation();
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startCursorAnimation() async {
  while (mounted) {
    await _controller.forward(from: 0);

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    _controller.reset();
  }
}

Widget buildCursor() {
  if (hintStep >= hintOrder.length) {
    return const SizedBox();
  }

  String currentShape = hintOrder[hintStep];
  int currentTarget = targetOrder[hintStep];

  /// posisi shape bawah
  final shapePosition = {
    "circle": Offset(w(20), h(740)),
    "triangle": Offset(w(80), h(740)),
    "horizontal": Offset(w(140), h(740)),
    "vertical": Offset(w(200), h(740)),
    "diag1": Offset(w(260), h(740)),
    "diag2": Offset(w(320), h(740)),
  };

  /// posisi kotak jawaban
  final targetPosition = {
    0: Offset(w(255), h(180)),
    1: Offset(w(255), h(275)),
    2: Offset(w(255), h(370)),
    3: Offset(w(255), h(465)),
    4: Offset(w(255), h(560)),
  };

  final start = shapePosition[currentShape]!;
  final end = targetPosition[currentTarget]!;

  return AnimatedBuilder(
    animation: _cursorAnim,
    builder: (context, child) {

      if (_controller.isDismissed) {
        return const SizedBox();
      }

      final dx =
          start.dx + (end.dx - start.dx) * _cursorAnim.value;

      final dy =
          start.dy + (end.dy - start.dy) * _cursorAnim.value;

      return Positioned(
        left: dx,
        top: dy ,
        child: Image.asset(
          'assets/images/cursor.png',
          width: w(40),
        ),
      );
    },
  );
}

  /// CEK SEMUA TERISI
  bool get allDropped => answers.every((e) => e.length == 2);

  /// RESET LEVEL
void restartMateri() {
  setState(() {

    answers = [
      [],
      [],
      [],
      [],
      [],
    ];

    hintStep = 0;

    lastCheckedStatus = null;
    hasWon = false;
  });
}

  /// ANIMASI & SOUND
  Future<void> showResultDialog(bool correct) async {
    if (correct) {
      setState(() {
        showWin = true;
        winAnimasi = "assets/lottie/benar.json";
      });

      await AudioManager().playEffect("sounds/benar.mp3");

      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        showWin = false;
      });
    } else {
      await AudioManager().playEffect("sounds/salah.mp3");

      await Future.delayed(const Duration(seconds: 2));

      restartMateri();
    }
  }

  /// AUTO CHECK
  void autoCheckAnswers() async {
    if (!allDropped || hasWon) return;

    bool allCorrect = true;

    for (int i = 0; i < answers.length; i++) {
      List<String> correct = List.from(correctMapping[i]!);
      List<String> user = List.from(answers[i]);

      correct.sort();
      user.sort();

      if (correct.toString() != user.toString()) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() {
        lastCheckedStatus = "correct";
        hasWon = true;
      });

      _controller.forward(from: 0);

      await showResultDialog(true);
    } else {
      setState(() {
        lastCheckedStatus = "wrong";
      });

      _controller.forward(from: 0);

      await showResultDialog(false);
    }
  }

  void _nextMateri() async {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Materi 11 berhasil terbuka!")),
    );

    Navigator.pop(context);
  }

  /// BOX SHAPE
  Widget shapeBox({CustomPainter? painter}) {
    return Container(
      width: w(70),
      height: h(70),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: CustomPaint(painter: painter),
    );
  }

  /// DROP BOX
  Widget dropBox(int index) {
    return DragTarget<String>(
onAccept: (data) {

  if (hintStep >= hintOrder.length) return;

  /// shape yg harus dipilih sekarang
  String expectedShape = hintOrder[hintStep];

  /// target box yg harus diisi sekarang
  int expectedBox = targetOrder[hintStep];

  /// jika salah shape atau salah box
  if (data != expectedShape || index != expectedBox) {
    return;
  }

  if (answers[index].length < 2) {

    setState(() {
      answers[index].add(data);
      hintStep++;
    });

    Future.delayed(
      const Duration(milliseconds: 300),
      autoCheckAnswers,
    );
  }
},
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: w(70),
          height: h(70),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2), // 🔥 selalu hitam
          ),
          child: Stack(
            children: answers[index].map((e) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: getPainter(e),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// ROW ITEM
  Widget rowItem({
    required int index,
    required CustomPainter left,
    required CustomPainter right,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          shapeBox(painter: left),
          SizedBox(width: w(10)),
          Text("+",
              style: TextStyle(fontSize: sp(28), fontWeight: FontWeight.bold)),
          SizedBox(width: w(10)),
          shapeBox(painter: right),
          SizedBox(width: w(10)),
          Text("=",
              style: TextStyle(fontSize: sp(28), fontWeight: FontWeight.bold)),
          SizedBox(width: w(10)),
          dropBox(index),
        ],
      ),
    );
  }

  /// DRAG ITEM
  Widget dragItem(String type) {
    return Draggable<String>(
      data: type,
      feedback: SizedBox(
        width: w(40),
        height: h(40),
        child: CustomPaint(
          painter: getPainter(type),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: SizedBox(
          width: w(40),
          height: h(40),
          child: CustomPaint(
            painter: getPainter(type),
          ),
        ),
      ),
      child: SizedBox(
        width: w(40),
        height: h(40),
        child: CustomPaint(
          painter: getPainter(type),
        ),
      ),
    );
  }

  /// MAPPING PAINTER
  CustomPainter getPainter(String type) {
    switch (type) {
      case "circle":
        return CirclePainter();

      case "triangle":
        return TrianglePainter();

      case "horizontal":
        return HorizontalPainter();

      case "vertical":
        return VerticalPainter();

      case "diag1":
        return DiagonalPainter1();

      case "diag2":
        return DiagonalPainter2();

      default:
        return CirclePainter();
    }
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
                SizedBox(height: h(25)),
                Text(
                  "Pilih garis sesuai petunjuk",
                  style: TextStyle(fontSize: sp(16)),
                ),
                SizedBox(height: h(25)),
                rowItem(
                    index: 0,
                    left: TrianglePainter(),
                    right: HorizontalPainter()),
                rowItem(
                    index: 1,
                    left: DiagonalPainter2(),
                    right: DiagonalPainter1()),
                rowItem(
                    index: 2, left: CirclePainter(), right: VerticalPainter()),
                rowItem(
                    index: 3,
                    left: DiagonalPainter2(),
                    right: HorizontalPainter()),
                rowItem(
                    index: 4,
                    left: DiagonalPainter1(),
                    right: VerticalPainter()),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: h(15)),
                  color: const Color(0xFFF7F7F7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      dragItem("circle"),
                      dragItem("triangle"),
                      dragItem("horizontal"),
                      dragItem("vertical"),
                      dragItem("diag1"),
                      dragItem("diag2"),
                    ],
                  ),
                ),
              ],
            ),
            buildCursor(),
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
                    await DBHive.completeMateri(10);

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

////////////////////////////
/// PAINTER
////////////////////////////

class DiagonalPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..color = Colors.black;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DiagonalPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..color = Colors.black;

    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class VerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..color = Colors.black;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HorizontalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..color = Colors.black;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

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
