import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level22Screen extends StatefulWidget {
  const Level22Screen({super.key});

  @override
  State<Level22Screen> createState() => _Level22ScreenState();
}

class _Level22ScreenState extends State<Level22Screen> {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  final GlobalKey stackKey = GlobalKey();

  /// POSISI DOT
  List<Offset?> dots = List.filled(20, null);

  /// BOX INDEX
  List<int> boxIndex = List.filled(20, 0);

  /// NUMBER VALUE
  List<int> numbers = [];

  /// CONNECTIONS
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

    numbers = [
      /// BOX1
      4, 3, 5, 1, 2,

      /// BOX2
      4, 5, 3, 1, 2,

      /// BOX3
      3, 2, 5, 4, 1,

      /// BOX4
      4, 3, 5, 1, 2,
    ];

    /// BOX ID
    boxIndex = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3];
  }

  Offset globalToLocal(Offset global) {
    RenderBox box = stackKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
  }

  /// WARNA ANGKA
  Color numberColor(int number) {
    switch (number) {
      case 1:
        return const Color(0xff4CAF6A);
      case 2:
        return const Color(0xff63A8D3);
      case 3:
        return const Color(0xffD779A5);
      case 4:
        return const Color(0xffE74C3C);
      case 5:
        return const Color(0xff6B63A6);
      default:
        return Colors.grey;
    }
  }

  /// NUMBER CIRCLE
  Widget numberCircle(int index) {
    int number = numbers[index];

    return GestureDetector(
      onPanStart: (d) {
        if (number == 5) return;

        setState(() {
          draggingIndex = index;
          currentDrag = globalToLocal(d.globalPosition);

          connections.removeWhere((c) => c["start"] == index);

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
          for (int i = 0; i < dots.length; i++) {
            if (dots[i] != null) {
              double dist = (dots[i]! - currentDrag!).distance;

              if (dist < 35) {
                /// harus kotak sama
                if (boxIndex[i] != boxIndex[index]) return;

                /// harus urutan angka
                if (numbers[i] != numbers[index] + 1) return;

                connections.removeWhere((c) => c["end"] == i);

                connections.add({"start": index, "end": i});
              }
            }
          }
        }

        setState(() {
          draggingIndex = null;
          currentDrag = null;
        });

        if (connections.length == 16) {
          autoCheckAnswers();
        }
      },
      child: Builder(builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          RenderBox box = context.findRenderObject() as RenderBox;

          Offset pos = box.localToGlobal(Offset.zero);

          dots[index] = globalToLocal(pos + const Offset(11, 11));
        });

        return Container(
          width: w(23),
          height: h(23),
          decoration: BoxDecoration(
            color: numberColor(number),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: sp(14),
            ),
          ),
        );
      }),
    );
  }

  /// AUTO CHECK
  Future<void> autoCheckAnswers() async {
    checked = true;

    bool allCorrect = true;

    for (var c in connections) {
      int start = c["start"]!;
      int end = c["end"]!;

      if (numbers[end] != numbers[start] + 1) {
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

  /// GAME BOX
  Widget gameBox(List<Widget> children) {
    return Stack(children: children);
  }

  /// GRID
  Widget buildGrid() {
    return Container(
      width: w(320),
      height: h(400),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 200,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: (index % 2 != 1) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: (index < 2) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: buildGameContent(index),
          );
        },
      ),
    );
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// POSISI NUMBER
  Widget buildGameContent(int index) {
    int start = index * 5;

    switch (index) {
      case 0:
        return gameBox([
          Positioned(top: h(20), left: w(62), child: numberCircle(start + 0)),
          Positioned(top: h(49), right: w(18), child: numberCircle(start + 1)),
          Positioned(top: h(82), left: w(30), child: numberCircle(start + 2)),
          Positioned(
              bottom: h(20), left: w(38), child: numberCircle(start + 3)),
          Positioned(
              bottom: h(39), right: w(17), child: numberCircle(start + 4)),
        ]);

      case 1:
        return gameBox([
          Positioned(top: h(20), right: w(47), child: numberCircle(start + 0)),
          Positioned(top: h(70), left: w(35), child: numberCircle(start + 1)),
          Positioned(top: h(100), right: w(25), child: numberCircle(start + 2)),
          Positioned(
              bottom: h(30), left: w(22), child: numberCircle(start + 3)),
          Positioned(
              bottom: h(20), right: w(18), child: numberCircle(start + 4)),
        ]);

      case 2:
        return gameBox([
          Positioned(top: h(30), left: w(50), child: numberCircle(start + 0)),
          Positioned(top: h(50), right: w(20), child: numberCircle(start + 1)),
          Positioned(
              bottom: h(74), left: w(20), child: numberCircle(start + 2)),
          Positioned(
              bottom: h(54), right: w(60), child: numberCircle(start + 3)),
          Positioned(
              bottom: h(20), right: w(18), child: numberCircle(start + 4)),
        ]);

      case 3:
        return gameBox([
          Positioned(top: h(17), left: w(64), child: numberCircle(start + 0)),
          Positioned(top: h(19), right: w(20), child: numberCircle(start + 1)),
          Positioned(top: h(42), left: w(20), child: numberCircle(start + 2)),
          Positioned(
              bottom: h(50), left: w(50), child: numberCircle(start + 3)),
          Positioned(
              bottom: h(30), right: w(30), child: numberCircle(start + 4)),
        ]);
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // base width 360 (HP kecil)
    scale = screenWidth / 360;

    return Scaffold(
      backgroundColor: const Color(0xffe9e9e9),
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
                SizedBox(height: h(50)),
                Text(
                  "Beri garis sesuai urutan angka",
                  style: TextStyle(fontSize: sp(18)),
                ),
                SizedBox(height: h(35)),
                buildGrid(),
              ],
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: LinePainter(
                  dots: dots,
                  connections: connections,
                  draggingIndex: draggingIndex,
                  currentDrag: currentDrag,
                  numbers: numbers,
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
                    await DBHive.unlockNextLevel(22);

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
  final List<Offset?> dots;
  final List<Map<String, int>> connections;
  final int? draggingIndex;
  final Offset? currentDrag;
  final List<int> numbers;
  final bool checked;

  LinePainter({
    required this.dots,
    required this.connections,
    required this.draggingIndex,
    required this.currentDrag,
    required this.numbers,
    required this.checked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var c in connections) {
      final start = dots[c["start"]!];
      final end = dots[c["end"]!];

      if (start != null && end != null) {
        Color color = Colors.black;

        if (checked) {
          color = numbers[c["end"]!] == numbers[c["start"]!] + 1
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

    if (draggingIndex != null && currentDrag != null) {
      final start = dots[draggingIndex!];

      if (start != null) {
        final paint = Paint()
          ..strokeWidth = 4
          ..color = Colors.orange;

        canvas.drawLine(start, currentDrag!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
