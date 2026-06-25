import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level36Screen extends StatefulWidget {
  const Level36Screen({super.key});

  @override
  State<Level36Screen> createState() => _Level36ScreenState();
}

class _Level36ScreenState extends State<Level36Screen> {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  final GlobalKey stackKey = GlobalKey();

  /// TEXT KIRI
  final List<String> leftTexts = [
    "Jenis sama,\nNama beda",
    "Bentuk sama,\nUkuran beda",
    "Nama sama,\nJumlah beda",
    "Nama sama,\nWarna beda",
    "Rasa sama,\nJenis beda",
  ];

  /// GAMBAR KANAN
  final List<String> rightImages = [
    "assets/images/36/1.png",
    "assets/images/36/2.png",
    "assets/images/36/3.png",
    "assets/images/36/4.png",
    "assets/images/36/5.png",
  ];

  /// MAPPING (index mulai dari 0)
  final Map<int, int> correctMapping = {
    0: 2,
    1: 4,
    2: 0,
    3: 1,
    4: 3,
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

  Offset globalToLocal(Offset global) {
    RenderBox box = stackKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
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
        setState(() {
          draggingIndex = index;
          currentDrag = globalToLocal(d.globalPosition);

          connections.removeWhere((c) => c["left"] == index);
          checked = false;
        });
      },
      onPanUpdate: (d) {
        setState(() {
          currentDrag = globalToLocal(d.globalPosition);
        });
      },
      onPanEnd: (d) {
        if (currentDrag != null) {
          for (int i = 0; i < rightDots.length; i++) {
            if (rightDots[i] != null) {
              double dist = (rightDots[i]! - currentDrag!).distance;

              if (dist < 40) {
                connections.removeWhere((c) => c["right"] == i);

                connections.add({"left": index, "right": i});
              }
            }
          }
        }

        setState(() {
          draggingIndex = null;
          currentDrag = null;
        });

        if (connections.length == 5) {
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

              leftDots[index] = globalToLocal(pos + const Offset(7, 7));
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

        rightDots[index] = globalToLocal(pos + const Offset(7, 7));
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

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
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
                    await DBHive.unlockNextLevel(36);

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
