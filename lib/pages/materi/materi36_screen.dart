import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi36Screen extends StatefulWidget {
  const Materi36Screen({super.key});

  @override
  State<Materi36Screen> createState() => _Materi36ScreenState();
}

class _Materi36ScreenState extends State<Materi36Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  final GlobalKey stackKey = GlobalKey();

  late AnimationController _controller;
late Animation<double> _cursorAnim;

int hintStep = 0;

bool dotsReady = false;

/// urutan penyelesaian
final List<Map<String, int>> hintOrder = [
  {"left": 0, "right": 1},
  {"left": 1, "right": 4},
  {"left": 2, "right": 2},
  {"left": 3, "right": 3},
  {"left": 4, "right": 0},
];

/// TEXT KIRI (acak)
final List<String> leftTexts = [
  "Nama sama,\nWarna beda",
  "Jenis sama,\nNama beda",
  "Rasa sama,\nJenis beda",
  "Nama sama,\nJumlah beda",
  "Bentuk sama,\nUkuran beda",
];

/// GAMBAR KANAN (acak)
final List<String> rightImages = [
  "assets/images/36/5.png",
  "assets/images/36/2.png",
  "assets/images/36/4.png",
  "assets/images/36/1.png",
  "assets/images/36/3.png",
];

/// MAPPING BARU
final Map<int, int> correctMapping = {
  0: 1, // Nama sama, Warna beda -> 2.png
  1: 4, // Jenis sama, Nama beda -> 3.png
  2: 2, // Rasa sama, Jenis beda -> 4.png
  3: 3, // Nama sama, Jumlah beda -> 1.png
  4: 0, // Bentuk sama, Ukuran beda -> 5.png
};

  List<Offset?> leftDots = List.filled(5, null);
  List<Offset?> rightDots = List.filled(5, null);

  List<Map<String, int>> connections = [];

  int? draggingIndex;
  Offset? currentDrag;

  bool checked = false;
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
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

  Offset globalToLocal(Offset global) {
    RenderBox box = stackKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
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

  /// BOX TEXT KIRI
  Widget textBox(String text) {
    return Container(
      width: w(110),
      height: h(80),
      padding: EdgeInsets.all(w(10)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(w(12)),
      ),
      child: Center(
        // 🔥 ini bikin vertical + horizontal center
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sp(13),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// BOX GAMBAR KANAN
  Widget imageBox(String asset) {
    return Container(
      width: w(110),
      height: h(80),
      padding: EdgeInsets.all(w(10)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(w(12)),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }

  /// DRAG KIRI
  Widget buildLeftArea(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
onPanStart: (d) {

  if (hintStep >= hintOrder.length) return;

  if (hintOrder[hintStep]["left"] != index) {
    return;
  }

  setState(() {
    draggingIndex = index;
    currentDrag = globalToLocal(d.globalPosition);

    connections.removeWhere(
      (c) => c["left"] == index,
    );

    checked = false;
  });
},
      onPanUpdate: (d) {
        setState(() {
          currentDrag = globalToLocal(d.globalPosition);
        });
      },
onPanEnd: (d) {

  if (hintStep >= hintOrder.length) {
    return;
  }

  final currentHint = hintOrder[hintStep];

  int requiredLeft =
      currentHint["left"]!;

  int requiredRight =
      currentHint["right"]!;

  if (draggingIndex != requiredLeft) {

    setState(() {
      draggingIndex = null;
      currentDrag = null;
    });

    return;
  }

  if (currentDrag != null) {

    for (int i = 0; i < rightDots.length; i++) {

      if (rightDots[i] == null) continue;

      double dist =
          (rightDots[i]! - currentDrag!)
              .distance;

      if (dist < 40) {

        if (i != requiredRight) {
          break;
        }

        connections.removeWhere(
          (c) => c["right"] == i,
        );

        connections.add({
          "left": requiredLeft,
          "right": requiredRight,
        });

        hintStep++;

        break;
      }
    }
  }

  setState(() {
    draggingIndex = null;
    currentDrag = null;
  });

  if (hintStep == hintOrder.length) {
    autoCheckAnswers();
  }
},
      child: Row(
        children: [
          textBox(leftTexts[index]),
          SizedBox(width: w(12)),
          Builder(builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset pos = box.localToGlobal(Offset.zero);

              leftDots[index] =
    globalToLocal(pos + const Offset(7, 7));

if (!dotsReady &&
    leftDots.every((e) => e != null) &&
    rightDots.every((e) => e != null)) {

  dotsReady = true;

  Future.microtask(() {
    if (mounted) setState(() {});
  });
}
            });

            return Container(
              width: w(10),
              height: h(10),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            );
          })
        ],
      ),
    );
  }

  Widget buildRightDot(int index) {
    return Builder(builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset pos = box.localToGlobal(Offset.zero);

        rightDots[index] =
    globalToLocal(pos + const Offset(7, 7));

if (!dotsReady &&
    leftDots.every((e) => e != null) &&
    rightDots.every((e) => e != null)) {

  dotsReady = true;

  Future.microtask(() {
    if (mounted) setState(() {});
  });
}
      });

      return Container(
        width: w(10),
        height: h(10),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      );
    });
  }

  Widget rowItem(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h(14), horizontal: w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildLeftArea(index),
          Row(
            children: [
              buildRightDot(index),
              SizedBox(width: w(12)),
              imageBox(rightImages[index]),
            ],
          )
        ],
      ),
    );
  }

  /// CEK JAWABAN
  Future<void> autoCheckAnswers() async {
    checked = true;

    bool allCorrect = true;

    for (var c in connections) {
      if (correctMapping[c["left"]] != c["right"]) {
        allCorrect = false;
      }
    }

    setState(() {});

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
      await AudioManager().playEffect('sounds/salah.mp3');

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        connections.clear();
        checked = false;
      });
    }
  }

  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }
Widget buildCursor() {

  if (!dotsReady) {
    return const SizedBox();
  }

  if (hintStep >= hintOrder.length) {
    return const SizedBox();
  }

  final current =
      hintOrder[hintStep];

  int left =
      current["left"]!;

  int right =
      current["right"]!;

  if (leftDots[left] == null ||
      rightDots[right] == null) {
    return const SizedBox();
  }

  final start =
      leftDots[left]!;

  final end =
      rightDots[right]!;

  return AnimatedBuilder(
    animation: _cursorAnim,
    builder: (context, child) {

      if (_controller.isDismissed) {
        return const SizedBox();
      }

      final dx =
          start.dx +
          (end.dx - start.dx) *
              _cursorAnim.value;

      final dy =
          start.dy +
          (end.dy - start.dy) *
              _cursorAnim.value;

      return Positioned(
        left: dx - w(5),
        top: dy - h(5),
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
          key: stackKey,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFFFBDF64),
                      alignment: Alignment.center,
                      child: Text(
                        'VARIABLE',
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
                  'Cocokkan dengan tepat',
                  style: TextStyle(
                    fontSize: sp(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h(20)),
                ...List.generate(5, (i) => rowItem(i)),
                const Spacer(),
              ],
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: LinePainter(
                  leftDots: leftDots,
                  rightDots: rightDots,
                  connections: connections,
                  correctMapping: correctMapping,
                  draggingIndex: draggingIndex,
                  currentDrag: currentDrag,
                  checked: checked,
                ),
                size: Size.infinite,
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
                    await DBHive.completeMateri(36);

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

/// PAINTER (SAMA)
class LinePainter extends CustomPainter {
  final List<Offset?> leftDots;
  final List<Offset?> rightDots;
  final List<Map<String, int>> connections;
  final Map<int, int> correctMapping;
  final int? draggingIndex;
  final Offset? currentDrag;
  final bool checked;

  LinePainter({
    required this.leftDots,
    required this.rightDots,
    required this.connections,
    required this.correctMapping,
    required this.draggingIndex,
    required this.currentDrag,
    required this.checked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var c in connections) {
      final start = leftDots[c["left"]!];
      final end = rightDots[c["right"]!];

      if (start != null && end != null) {
        Color color = Colors.black;

        if (checked) {
          color = correctMapping[c["left"]] == c["right"]
              ? Colors.green
              : Colors.red;
        }

        final paint = Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = color;

        canvas.drawLine(start, end, paint);
      }
    }

    if (draggingIndex != null &&
        currentDrag != null &&
        leftDots[draggingIndex!] != null) {
      final paint = Paint()
        ..strokeWidth = 4
        ..color = Colors.orange;

      canvas.drawLine(
        leftDots[draggingIndex!]!,
        currentDrag!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
