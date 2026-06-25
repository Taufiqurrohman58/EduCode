import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level27Screen extends StatefulWidget {
  const Level27Screen({super.key});

  @override
  State<Level27Screen> createState() => _Level27ScreenState();
}

class _Level27ScreenState extends State<Level27Screen> {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  final GlobalKey stackKey = GlobalKey();

  /// GRID DATA
  final List<List<int>> leftGrid = [
    [1, 2], // kiri 1
    [2, 3], // kiri 2
    [0, 3], // kiri 3
    [0, 1], // kiri 4
  ];

  final List<List<int>> rightGrid = [
    [0, 1], // kanan 1
    [0, 3], // kanan 2
    [2, 3], // kanan 3
    [1, 2], // kanan 4
  ];

  /// MAPPING BENAR
  final Map<int, int> correctMapping = {
    0: 1,
    1: 0,
    2: 3,
    3: 2,
  };

  List<Offset?> leftDots = List.filled(4, null);
  List<Offset?> rightDots = List.filled(4, null);

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

  /// GRID 2x2
  Widget buildGrid(List<int> greenCells) {
    return Container(
      width: w(90),
      height: h(45),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
        ),
        itemBuilder: (context, index) {
          bool isGreen = greenCells.contains(index);

          return Container(
            decoration: BoxDecoration(
              color: isGreen ? Colors.green : Colors.transparent,
              border: Border(
                right: BorderSide(
                  color: (index % 2 != 1) ? Colors.black : Colors.transparent,
                ),
                bottom: BorderSide(
                  color: (index < 2) ? Colors.black : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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

        if (connections.length == 4) {
          autoCheckAnswers();
        }
      },
      child: Row(
        children: [
          buildGrid(leftGrid[index]),
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
      padding: EdgeInsets.symmetric(vertical: h(30), horizontal: w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildLeftArea(index),
          Row(
            children: [
              buildRightDot(index),
              SizedBox(width: w(12)),
              buildGrid(rightGrid[index]),
            ],
          )
        ],
      ),
    );
  }

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
                /// HEADER
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFFE27AAF),
                      alignment: Alignment.center,
                      child: Text(
                        'CONDITION',
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

                /// INSTRUKSI
                Text(
                  "Pasangkan pola yang sama",
                  style: TextStyle(
                    fontSize: sp(18),
                  ),
                ),

                SizedBox(height: h(20)),

                /// LABEL KIRI KANAN
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "JIKA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sp(16),
                        ),
                      ),
                      Text(
                        "MAKA SISANYA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sp(16),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h(10)),

                /// GRID
                ...List.generate(4, (i) => rowItem(i)),

                const Spacer(),
              ],
            ),

            /// GARIS
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

            /// ANIMASI MENANG
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

      /// BUTTON LANJUT
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(27);

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
