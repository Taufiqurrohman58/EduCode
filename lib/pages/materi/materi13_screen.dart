import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi13Screen extends StatefulWidget {
  const Materi13Screen({super.key});

  @override
  State<Materi13Screen> createState() => _Materi13ScreenState();
}

class _Materi13ScreenState extends State<Materi13Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// GRID UTAMA 6x6
  final List<List<dynamic>> gridData = const [
    [
      "assets/images/13/pohon.jpg",
      "assets/images/13/ular.jpg",
      "assets/images/13/pohon.jpg",
      "assets/images/13/pohon.jpg",
      "assets/images/13/gajah.jpg",
      "assets/images/13/pohon.jpg",
    ],
    [
      "assets/images/13/pohon.jpg",
      null,
      "assets/images/13/pohon.jpg",
      null,
      null,
      null,
    ],
    [
      "assets/images/13/kudanil.jpg",
      null,
      "assets/images/13/pohon.jpg",
      null,
      "assets/images/13/pohon.jpg",
      null,
    ],
    [
      "assets/images/13/pohon.jpg",
      null,
      null,
      "start",
      "assets/images/13/pohon.jpg",
      "assets/images/13/ular.jpg",
    ],
    [
      "assets/images/13/pohon.jpg",
      null,
      "assets/images/13/pohon.jpg",
      null,
      "assets/images/13/pohon.jpg",
      "assets/images/13/pohon.jpg",
    ],
    [
      "assets/images/13/pohon.jpg",
      "assets/images/13/rusa.jpg",
      "assets/images/13/pohon.jpg",
      null,
      null,
      "assets/images/13/jerapah.jpg",
    ],
  ];

  /// ================= MAPPING JAWABAN =================
  final List<List<String?>> correctMapping = [
    ["left", "left", "down", "down", null, null], //1
    ["down", "down", "right", "right", null, null], //2
    ["up", "up", "right", "up", null, null], //3
    ["left", "left", "up", "left", null, null], //4
  ];

  /// ================= GRID HEWAN =================
  final List<List<String?>> animalGrid = [
    ["assets/images/13/rusa.jpg", null, null, null, null, null, null], //1
    ["assets/images/13/jerapah.jpg", null, null, null, null, null, null], //2
    ["assets/images/13/gajah.jpg", null, null, null, null, null, null], //3
    ["assets/images/13/kudanil.jpg", null, null, null, null, null, null], //4
  ];

  /// ================= STATE =================
  List<List<String>> answers = [[], [], [], []];

  int hintStep = 0;

  /// urutan pengisian
  final List<Map<String, dynamic>> hintOrder = [
    // RUSA
    {"row": 0, "col": 0, "arrow": "left"},
    {"row": 0, "col": 1, "arrow": "left"},
    {"row": 0, "col": 2, "arrow": "down"},
    {"row": 0, "col": 3, "arrow": "down"},

    // JERAPAH
    {"row": 1, "col": 0, "arrow": "down"},
    {"row": 1, "col": 1, "arrow": "down"},
    {"row": 1, "col": 2, "arrow": "right"},
    {"row": 1, "col": 3, "arrow": "right"},

    // GAJAH
    {"row": 2, "col": 0, "arrow": "up"},
    {"row": 2, "col": 1, "arrow": "up"},
    {"row": 2, "col": 2, "arrow": "right"},
    {"row": 2, "col": 3, "arrow": "up"},

    // KUDANIL
    {"row": 3, "col": 0, "arrow": "left"},
    {"row": 3, "col": 1, "arrow": "left"},
    {"row": 3, "col": 2, "arrow": "up"},
    {"row": 3, "col": 3, "arrow": "left"},
  ];

  String? lastCheckedStatus;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  late AnimationController _cursorController;
  late Animation<double> _cursorAnim;
  late Animation<double> _bounceAnim;

  bool get canRun {
    return answers.every((row) => row.length >= 4);
  }

  @override
  void initState() {
    super.initState();

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cursorAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _cursorController,
        curve: Curves.easeInOut,
      ),
    );

    _bounceAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(
      CurvedAnimation(
        parent: _cursorController,
        curve: Curves.easeInOut,
      ),
    );

    startCursorAnimation();
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  void startCursorAnimation() async {
    while (mounted) {
      await _cursorController.forward(from: 0);

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      _cursorController.reset();
    }
  }

  /// ================= RESET =================
  void restartMateri() {
    setState(() {
      hintStep = 0;
      answers = [[], [], [], []];
      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  /// ================= IMAGE =================
  String getImage(String type) {
    switch (type) {
      case "left":
        return "assets/images/panah_kiri.png";
      case "right":
        return "assets/images/panah_kanan.png";
      case "up":
        return "assets/images/panah_atas.png";
      case "down":
        return "assets/images/panah_bawah.png";
      default:
        return "";
    }
  }

  /// ================= RESULT =================
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

  /// ================= CHECK ANSWER =================
  void checkAnswer() async {
    bool allCorrect = true;

    for (int row = 0; row < correctMapping.length; row++) {
      for (int col = 0; col < correctMapping[row].length; col++) {
        String? correct = correctMapping[row][col];

        String? user = col < answers[row].length ? answers[row][col] : null;

        if (correct != user) {
          allCorrect = false;
        }
      }
    }

    if (allCorrect) {
      setState(() {
        lastCheckedStatus = "correct";
        hasWon = true;
      });

      await showResultDialog(true);
    } else {
      setState(() {
        lastCheckedStatus = "wrong";
      });

      await showResultDialog(false);
    }
  }

  /// ================= DROP BOX =================
  Widget dropBox(int row, int col) {
    String? value = col < answers[row].length ? answers[row][col] : null;

    return DragTarget<String>(
      onAccept: (data) {
        if (hintStep >= hintOrder.length) return;

        final current = hintOrder[hintStep];

        if (current["row"] != row) return;

        if (current["col"] != col) return;

        if (current["arrow"] != data) return;

        setState(() {
          if (answers[row].length > col) {
            answers[row][col] = data;
          } else {
            answers[row].add(data);
          }

          hintStep++;
        });
      },
      builder: (context, candidate, rejected) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                child: value != null
                    ? Image.asset(getImage(value))
                    : const SizedBox(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCursor() {
    if (hintStep >= hintOrder.length) {
      return buildRunCursor();
    }

    final current = hintOrder[hintStep];

    final arrow = current["arrow"];
    final row = current["row"];
    final col = current["col"];

    /// posisi panah bawah
    final arrowPos = {
      "left": Offset(w(35), h(760)),
      "right": Offset(w(110), h(760)),
      "up": Offset(w(185), h(760)),
      "down": Offset(w(260), h(760)),
    };

    /// posisi grid jawaban
    final startX = w(90);
    final startY = h(520);

    final end = Offset(
      startX + (col * w(45)),
      startY + (row * h(45)),
    );

    final start = arrowPos[arrow]!;

    return AnimatedBuilder(
      animation: _cursorAnim,
      builder: (_, __) {
        if (_cursorController.isDismissed) {
          return const SizedBox();
        }

        final dx = start.dx + (end.dx - start.dx) * _cursorAnim.value;

        final dy = start.dy + (end.dy - start.dy) * _cursorAnim.value;

        return Positioned(
          left: dx,
          top: dy,
          child: Image.asset(
            "assets/images/cursor.png",
            width: w(40),
          ),
        );
      },
    );
  }

  Widget buildRunCursor() {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (_, __) {
        return Positioned(
          right: w(70),
          bottom: h(35) + _bounceAnim.value,
          child: Image.asset(
            "assets/images/cursor.png",
            width: w(45),
          ),
        );
      },
    );
  }

  Widget buildMainGrid() {
    return Center(
      child: Container(
        width: w(320),
        height: h(320),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          children: List.generate(gridData.length, (row) {
            return Expanded(
              child: Row(
                children: List.generate(gridData[row].length, (col) {
                  var value = gridData[row][col];

                  Widget child;

                  if (value == null) {
                    child = const SizedBox();
                  } else if (value == "start") {
                    child = Container(
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: const Text(
                        "START",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    child = Padding(
                      padding: EdgeInsets.all(w(5)),
                      child: Image.asset(
                        value,
                        fit: BoxFit.contain,
                      ),
                    );
                  }

                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: col != gridData[row].length - 1
                                ? Colors.black
                                : Colors.transparent,
                          ),
                          bottom: BorderSide(
                            color: row != gridData.length - 1
                                ? Colors.black
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// ================= GRID =================
  Widget buildGrid4x7() {
    return Container(
      width: w(320),
      height: h(180),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: List.generate(animalGrid.length, (row) {
          return Expanded(
            child: Row(
              children: List.generate(animalGrid[row].length, (col) {
                String? imagePath = animalGrid[row][col];

                Widget child;

                if (col > 0 && col < 7) {
                  child = dropBox(row, col - 1);
                } else {
                  child = imagePath != null
                      ? Padding(
                          padding: EdgeInsets.all(w(5)),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const SizedBox();
                }

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: col != animalGrid[row].length - 1
                              ? Colors.black
                              : Colors.transparent,
                        ),
                        bottom: BorderSide(
                          color: row != animalGrid.length - 1
                              ? Colors.black
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: child,
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  /// ================= DRAG =================
  Widget dragItem(String type) {
    return Draggable<String>(
      data: type,
      feedback: Image.asset(getImage(type), width: w(40)),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(getImage(type), width: w(40)),
      ),
      child: Image.asset(getImage(type), width: w(40)),
    );
  }

  /// ================= BOTTOM =================
  Widget buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: h(15)),
      color: const Color(0xFFF7F7F7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          dragItem("left"),
          dragItem("right"),
          dragItem("up"),
          dragItem("down"),

          /// RUN BUTTON
          GestureDetector(
            onTap: () {
              if (canRun) {
                checkAnswer();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Isi minimal 4 langkah di setiap baris!"),
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(w(10)),
              decoration: BoxDecoration(
                color: canRun
                    ? const Color(0xFFFFE082) // aktif (kuning)
                    : Colors.grey, // nonaktif (abu)
                border: Border.all(
                  color: canRun ? Colors.orangeAccent : Colors.grey.shade600,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(w(14)),
              ),
              child: Opacity(
                opacity: canRun ? 1 : 0.5, // biar keliatan disable
                child: Image.asset(
                  "assets/images/run.png",
                  width: w(20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// ================= NEXT LEVEL =================
  void _nextMateri() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Materi 14 terbuka!")),
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
                /// HEADER
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFF62B4E4),
                      alignment: Alignment.center,
                      child: Text(
                        'ALGORITHM',
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
                Text(
                  "Gambarkan panah yang sesuai",
                  style: TextStyle(fontSize: sp(16)),
                ),

                SizedBox(height: h(25)),

                buildMainGrid(),

                SizedBox(height: h(30)),

                buildGrid4x7(),

                const Spacer(),

                buildBottomBar(),
              ],
            ),
            buildCursor(),

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
                    await DBHive.completeMateri(13);

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
