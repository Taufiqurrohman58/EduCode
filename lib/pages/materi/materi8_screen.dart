import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi8Screen extends StatefulWidget {
  const Materi8Screen({super.key});

  @override
  State<Materi8Screen> createState() => _Materi8ScreenState();
}

class _Materi8ScreenState extends State<Materi8Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  int activeCell = -1;


  /// ===========================
/// HINT CURSOR
/// ===========================

int hintStep = 0;

late Animation<double> _cursorAnim;

/// urutan penyelesaian
final List<Map<String, dynamic>> hintOrder = [
  {"cell": 0, "line": 0},
  {"cell": 0, "line": 1},
  {"cell": 0, "line": 2},

  {"cell": 1, "line": 0},
  {"cell": 1, "line": 1},
  {"cell": 1, "line": 2},

  {"cell": 2, "line": 0},
  {"cell": 2, "line": 1},
  {"cell": 2, "line": 2},

  {"cell": 3, "line": 0},
  {"cell": 3, "line": 1},
  {"cell": 3, "line": 2},
];

  List<Offset?> drawnPoints = [];

  Map<int, List<LineSegment>> completedLines = {
    0: [],
    1: [],
    2: [],
    3: [],
  };

  List<List<LineSegment>> baseLines = [];
  List<List<LineSegment>> missingLines = [];

  /// ===== LEVEL1 STYLE VARIABLE =====
  late AnimationController _controller;

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  @override
  void initState() {
    super.initState();

_controller = AnimationController(
  duration: const Duration(milliseconds: 1200),
  vsync: this,
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
    generatePuzzle();
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

  /// =========================
  /// GENERATE PUZZLE
  /// =========================
  void generatePuzzle() {
    for (int i = 0; i < 4; i++) {
      final nodes = generateNodes();

      final A = nodes["A"]!;
      final B = nodes["B"]!;
      final C = nodes["C"]!;
      final D = nodes["D"]!;
      final G = nodes["G"]!;
      final E = nodes["E"]!;
      final F = nodes["F"]!;
      final H = nodes["H"]!;
      final I = nodes["I"]!;

      List<LineSegment> base = [];
      List<LineSegment> missing = [];

      switch (i) {
        case 3:
          base = [
            LineSegment(B, C),
            LineSegment(A, D),
            LineSegment(C, G),
            LineSegment(E, F),
            LineSegment(A, C),
            LineSegment(D, G),
          ];

          missing = [
            LineSegment(A, B),
            LineSegment(E, H),
            LineSegment(F, I),
          ];
          break;
        case 2:
          base = [
            LineSegment(B, C),
            LineSegment(A, D),
            LineSegment(F, I),
            LineSegment(A, B),
            LineSegment(C, G),
            LineSegment(E, H),
          ];

          missing = [
            LineSegment(A, C),
            LineSegment(D, G),
            LineSegment(E, F),
          ];
          break;
        case 1:
          base = [
            LineSegment(A, B),
            LineSegment(D, G),
            LineSegment(E, F),
            LineSegment(B, C),
            LineSegment(A, D),
            LineSegment(F, I),
          ];

          missing = [
            LineSegment(A, C),
            LineSegment(C, G),
            LineSegment(E, H),
          ];
          break;
        case 0:
          base = [
            LineSegment(A, B),
            LineSegment(A, C),
            LineSegment(C, G),
            LineSegment(D, G),
            LineSegment(E, F),
            LineSegment(E, H),
          ];

          missing = [
            LineSegment(B, C),
            LineSegment(A, D),
            LineSegment(F, I),
          ];
          break;
      }

      baseLines.add(base);
      missingLines.add(missing);
    }
  }

  /// =========================
  /// NODE RUMAH
  /// =========================
  Map<String, Offset> generateNodes() {
    double size = 160;
    double center = size / 2;
    double s = size * 0.55;

    Offset A = Offset(center - s * 0.5, center - s * 0.1);
    Offset B = Offset(center, center - s * 0.6);
    Offset C = Offset(center + s * 0.5, center - s * 0.1);

    Offset D = Offset(center - s * 0.5, center + s * 0.6);
    Offset G = Offset(center + s * 0.5, center + s * 0.6);

    Offset H = Offset(center - s * 0.15, D.dy);
    Offset I = Offset(center + s * 0.15, G.dy);

    double doorWidth = I.dx - H.dx;
    double doorHeight = doorWidth;

    Offset E = Offset(H.dx, H.dy - doorHeight);
    Offset F = Offset(I.dx, I.dy - doorHeight);

    return {
      "A": A,
      "B": B,
      "C": C,
      "D": D,
      "G": G,
      "E": E,
      "F": F,
      "H": H,
      "I": I,
    };
  }

  Offset getCellOffset(int cell) {
  switch (cell) {
    case 0:
      return Offset(0, 0);

    case 1:
      return Offset(w(160), 0);

    case 2:
      return Offset(0, h(160));

    case 3:
      return Offset(w(160), h(160));

    default:
      return Offset.zero;
  }
}

  /// =========================
  /// AUTO CHECK (LEVEL1 STYLE)
  /// =========================
  void autoCheckAnswers() async {
    bool allComplete = true;

    for (int i = 0; i < 4; i++) {
      if (completedLines[i]!.length != missingLines[i].length) {
        allComplete = false;
        break;
      }
    }

    if (allComplete && !hasWon) {
      setState(() {
        hasWon = true;
      });

      await showResultDialog(true);
    }
  }

  /// =========================
  /// RESULT DIALOG
  /// =========================
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
    }
  }

  /// =========================
  /// DRAW UPDATE
  /// =========================
  void handlePanUpdate(Offset p) {
    setState(() {
      drawnPoints.add(p);
    });
  }

  /// =========================
  /// DRAW END
  /// =========================
void handlePanEnd() {
  if (activeCell == -1 || drawnPoints.length < 2) {
    drawnPoints.clear();
    return;
  }

  if (hintStep >= hintOrder.length) {
    drawnPoints.clear();
    return;
  }

  final currentHint = hintOrder[hintStep];

  int requiredCell = currentHint["cell"];
  int requiredLineIndex = currentHint["line"];

  /// harus cell yang benar
  if (activeCell != requiredCell) {
    drawnPoints.clear();

    setState(() {});

    return;
  }

  LineSegment userLine = LineSegment(
    drawnPoints.first!,
    drawnPoints.last!,
  );

  LineSegment targetLine =
      missingLines[requiredCell][requiredLineIndex];

  if (userLine.isCloseTo(targetLine)) {
    setState(() {
      completedLines[requiredCell]!.add(
        targetLine,
      );

      hintStep++;
    });

    autoCheckAnswers();
  }

  drawnPoints.clear();
}

  /// =========================
  /// GRID
  /// =========================
  Widget buildGrid2x2() {
    return Container(
      width: w(320),
      height: h(320),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onPanStart: (_) {
              activeCell = index;
            },
            onPanUpdate: (details) {
              handlePanUpdate(details.localPosition);
            },
            onPanEnd: (_) {
              handlePanEnd();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: (index % 2 != 1) ? Colors.black : Colors.transparent,
                  ),
                  bottom: BorderSide(
                    color: (index < 2) ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
              child: CustomPaint(
                painter: DrawingPainter(
                  baseLines: baseLines[index],
                  missingLines: missingLines[index],
                  completedLines: completedLines[index]!,
                  drawnPoints: activeCell == index ? drawnPoints : [],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _nextMateri8Screen() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi8Screen 9 terbuka')),
    );

    Navigator.pop(context);
  }
  Widget buildCursor() {
  if (hintStep >= hintOrder.length) {
    return const SizedBox();
  }

  final current = hintOrder[hintStep];

  int cell = current["cell"];
  int lineIndex = current["line"];

  final line = missingLines[cell][lineIndex];

  final cellOffset = getCellOffset(cell);

  final start = Offset(
    line.start.dx + cellOffset.dx,
    line.start.dy + cellOffset.dy,
  );

  final end = Offset(
    line.end.dx + cellOffset.dx,
    line.end.dy + cellOffset.dy,
  );

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
        left: dx + w(10),
        top: dy + h(295),
        child: Image.asset(
          'assets/images/cursor.png',
          width: w(40),
        ),
      );
    },
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
            SingleChildScrollView(
              child: Column(
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
                                AudioManager()
                                    .playVoice('sounds/level_1&2.mp3');
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
                  Text(
                    "Gambarkan garis yang hilang sesuai contoh",
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: h(30)),

                  /// CONTOH RUMAH
                  Image.asset(
                    "assets/images/contoh_rumah.png",
                    width: w(200),
                  ),

                  SizedBox(height: h(50)),

                  buildGrid2x2(),
                ],
              ),
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
                    await DBHive.unlockNextLevel(8);

                    _nextMateri8Screen();

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

class LineSegment {
  final Offset start;
  final Offset end;

  LineSegment(this.start, this.end);

  bool isCloseTo(LineSegment other) {
    double d1 = distanceToSegment(other.start);
    double d2 = distanceToSegment(other.end);

    return d1 < 20 && d2 < 20;
  }

  double distanceToSegment(Offset point) {
    double A = point.dx - start.dx;
    double B = point.dy - start.dy;
    double C = end.dx - start.dx;
    double D = end.dy - start.dy;

    double dot = A * C + B * D;
    double lenSq = C * C + D * D;
    double param = lenSq != 0 ? dot / lenSq : -1;

    double xx, yy;

    if (param < 0) {
      xx = start.dx;
      yy = start.dy;
    } else if (param > 1) {
      xx = end.dx;
      yy = end.dy;
    } else {
      xx = start.dx + param * C;
      yy = start.dy + param * D;
    }

    double dx = point.dx - xx;
    double dy = point.dy - yy;

    return Math.sqrt(dx * dx + dy * dy);
  }
}

class DrawingPainter extends CustomPainter {
  final List<LineSegment> baseLines;
  final List<LineSegment> missingLines;
  final List<LineSegment> completedLines;
  final List<Offset?> drawnPoints;

  DrawingPainter({
    required this.baseLines,
    required this.missingLines,
    required this.completedLines,
    required this.drawnPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    final completePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;

    final drawPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;

    final guidePaint = Paint()
      ..color = Colors.grey.withOpacity(0)
      ..strokeWidth = 2;

    for (var line in baseLines) {
      canvas.drawLine(line.start, line.end, basePaint);
    }

    for (var line in missingLines) {
      if (!completedLines.contains(line)) {
        drawDashedLine(canvas, line.start, line.end, guidePaint);
      }
    }

    for (var line in completedLines) {
      canvas.drawLine(line.start, line.end, completePaint);
    }

    for (int i = 0; i < drawnPoints.length - 1; i++) {
      if (drawnPoints[i] != null && drawnPoints[i + 1] != null) {
        canvas.drawLine(
          drawnPoints[i]!,
          drawnPoints[i + 1]!,
          drawPaint,
        );
      }
    }
  }

  void drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 6;
    const dashSpace = 6;

    double distance = (p2 - p1).distance;

    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;

    double startX = p1.dx;
    double startY = p1.dy;

    while (distance > 0) {
      final x2 = startX + dx * dashWidth;
      final y2 = startY + dy * dashWidth;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(x2, y2),
        paint,
      );

      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);

      distance -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
