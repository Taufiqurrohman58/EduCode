import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi11Screen extends StatefulWidget {
  const Materi11Screen({super.key});

  @override
  State<Materi11Screen> createState() => _Materi11ScreenState();
}

class _Materi11ScreenState extends State<Materi11Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// GRID DATA
  final List<List<String?>> gridData = [
    ["assets/images/pohon.jpg", null, null, null, "assets/images/pohon.jpg"],
    [
      "assets/images/pohon.jpg",
      "assets/images/orang.jpg",
      "assets/images/pohon.jpg",
      null,
      null
    ],
    [
      "assets/images/pohon.jpg",
      null,
      "assets/images/pohon.jpg",
      "assets/images/pohon.jpg",
      null
    ],
    [
      "assets/images/singa.jpg",
      null,
      "assets/images/pohon.jpg",
      "assets/images/rumah.jpg",
      null
    ],
    [
      "assets/images/pohon.jpg",
      null,
      "assets/images/buaya.jpg",
      "assets/images/pohon.jpg",
      null
    ],
  ];

  /// SLOT DROP
  Map<String, String?> droppedRoads = {};

  /// =======================
/// HINT STEP
/// =======================

int hintStep = 0;

/// urutan pemasangan jalan
final List<Map<String, String>> hintOrder = [
  {"road": "jalan_f_1", "slot": "0_1"},
  {"road": "jalan_a_1", "slot": "0_2"},
  {"road": "jalan_c_1", "slot": "0_3"},
  {"road": "jalan_d_1", "slot": "1_3"},
  {"road": "jalan_c_2", "slot": "1_4"},
  {"road": "jalan_b_1", "slot": "2_4"},
  {"road": "jalan_e_1", "slot": "3_4"},
];

  int get droppedCount =>
    droppedRoads.values.where((e) => e != null).length;

  /// ITEM DRAG
/// ITEM DRAG
List<String> availableRoads = [
  'jalan_c_2',
  'jalan_a_1',
  'jalan_f_1',
  'jalan_b_2',
  'jalan_d_1',
  'jalan_a_3',
  'jalan_e_1',
  'jalan_b_1',
  'jalan_c_1',
  'jalan_a_2',
];

  String getRealImage(String name) {
    if (name.startsWith('jalan_a')) return 'jalan_a.jpg';
    if (name.startsWith('jalan_b')) return 'jalan_b.jpg';
    if (name.startsWith('jalan_c')) return 'jalan_c.jpg';
    if (name.startsWith('jalan_d')) return 'jalan_d.jpg';
    if (name.startsWith('jalan_e')) return 'jalan_e.jpg';
    if (name.startsWith('jalan_f')) return 'jalan_f.jpg';
    return name;
  }

  bool isMatch(String? value, String prefix) {
  return value != null && value.startsWith(prefix);
}

  void checkAnswers() async {
    if (droppedCount != 7 || hasWon) return;

    bool correct = true;

    // mapping posisi
    if (!isMatch(droppedRoads["0_1"], "jalan_f")) correct = false;
    if (!isMatch(droppedRoads["0_2"], "jalan_a")) correct = false;
    if (!isMatch(droppedRoads["0_3"], "jalan_c")) correct = false;
    if (!isMatch(droppedRoads["1_3"], "jalan_d")) correct = false;
    if (!isMatch(droppedRoads["1_4"], "jalan_c")) correct = false;
    if (!isMatch(droppedRoads["2_4"], "jalan_b")) correct = false;
    if (!isMatch(droppedRoads["3_4"], "jalan_e")) correct = false;

    if (correct) {
      setState(() {
        hasWon = true;
      });

      _controller.forward(from: 0);
      await showResultDialog(true);
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jawaban masih salah!")),
      );

      /// 🔥 tunggu 3 detik lalu reset
      await Future.delayed(const Duration(seconds: 3));

      resetMateri();
    }
  }

  /// ANIMATION
  late AnimationController _controller;
late AnimationController _cursorController;
late Animation<double> _cursorAnim;
late Animation<double> _bounceAnim;

  bool showWin = false;
  String? winAnimasi;
  bool hasWon = false;

  /// CEK JIKA ITEM SUDAH HABIS
  bool get allDropped => availableRoads.isEmpty;

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

    /// INISIALISASI SLOT DROP
    for (int r = 0; r < gridData.length; r++) {
      for (int c = 0; c < gridData[r].length; c++) {
        if (gridData[r][c] == null) {
          droppedRoads["${r}_${c}"] = null;
        }
      }
    }
  }

  @override
  void dispose() {
_controller.dispose();
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

  /// AUTO CHECK
  void autoCheckAnswers() async {
    if (!allDropped || hasWon) return;

    setState(() {
      hasWon = true;
    });

    _controller.forward(from: 0);

    await showResultDialog(true);
  }

  /// ANIMASI MENANG
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

  void resetMateri() {
    setState(() {
      /// kosongkan semua slot
      droppedRoads.updateAll((key, value) => null);

      /// kembalikan item ke awal
      availableRoads = [
        'jalan_a_1',
        'jalan_b_1',
        'jalan_a_2',
        'jalan_b_2',
        'jalan_a_3',
        'jalan_c_1',
        'jalan_d_1',
        'jalan_c_2',
        'jalan_e_1',
        'jalan_f_1',
      ];

      /// reset state
      hasWon = false;
      showWin = false;
    });
  }

  /// DRAG ITEM JALAN
  Widget dashedRoad(String assetName) {
    return Draggable<String>(
      data: assetName,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset("assets/images/${getRealImage(assetName)}",
          width: w(50),
          height: h(50),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset("assets/images/${getRealImage(assetName)}",
          width: w(40),
        ),
      ),
      child: Container(
        width: w(50),
        height: h(50),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Image.asset("assets/images/${getRealImage(assetName)}"),
      ),
    );
  }

  /// LIST ITEM DRAG
  Widget buildRoadRows() {
    final topRow = availableRoads.take(5).toList();
    final bottomRow = availableRoads.skip(5).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: topRow.map((a) => dashedRoad(a)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: bottomRow.map((a) => dashedRoad(a)).toList(),
        ),
      ],
    );
  }

  Widget buildCursor() {
  if (hintStep >= hintOrder.length) {
    return buildRunCursor();
  }

  final current = hintOrder[hintStep];

  final road = current["road"]!;
  final slot = current["slot"]!;

  /// posisi item bawah
  final roadPosition = {
    "jalan_f_1": Offset(w(35), h(640)),
    "jalan_a_1": Offset(w(95), h(640)),
    "jalan_c_1": Offset(w(335), h(700)),
    "jalan_d_1": Offset(w(215), h(700)),
    "jalan_c_2": Offset(w(35), h(700)),
    "jalan_b_1": Offset(w(275), h(700)),
    "jalan_e_1": Offset(w(95), h(700)),
  };

  /// posisi slot grid
  final slotPosition = {
    "0_1": Offset(w(120), h(230)),
    "0_2": Offset(w(180), h(230)),
    "0_3": Offset(w(240), h(230)),
    "1_3": Offset(w(240), h(290)),
    "1_4": Offset(w(300), h(290)),
    "2_4": Offset(w(300), h(350)),
    "3_4": Offset(w(300), h(410)),
  };

  final start = roadPosition[road]!;
  final end = slotPosition[slot]!;

  return AnimatedBuilder(
    animation: _cursorAnim,
    builder: (_, __) {
      if (_cursorController.isDismissed) {
        return const SizedBox();
      }

      final dx =
          start.dx + (end.dx - start.dx) * _cursorAnim.value;

      final dy =
          start.dy + (end.dy - start.dy) * _cursorAnim.value;

      return Positioned(
        left: dx,
        top: dy,
        child: Image.asset(
          'assets/images/cursor.png',
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
        bottom: h(145) + _bounceAnim.value,
        child: Image.asset(
          'assets/images/cursor.png',
          width: w(45),
        ),
      );
    },
  );
}

  /// KOTAK DROP
  Widget buildDropBox(int row, int col) {
    String key = "${row}_${col}";
    String? dropped = droppedRoads[key];

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
  final road = details.data;

  final currentHint = hintOrder[hintStep];

  /// hanya boleh jalan sesuai petunjuk
  if (road != currentHint["road"]) {
    return;
  }

  /// hanya boleh slot sesuai petunjuk
  if (key != currentHint["slot"]) {
    return;
  }

  setState(() {
    droppedRoads[key] = road;
    availableRoads.remove(road);

    hintStep++;
  });

  if (hintStep >= hintOrder.length) {
    Future.delayed(
      const Duration(milliseconds: 300),
      checkAnswers,
    );
  }
},

      builder: (context, candidateData, rejectedData) {
        return Container(
          alignment: Alignment.center,
          child: dropped == null
              ? const SizedBox()
              : Draggable<String>(
                  data: dropped,

                  /// 🔥 feedback drag
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset("assets/images/${getRealImage(dropped)}",
                      width: w(50),
                      height: h(50),
                    ),
                  ),

                  /// 🔥 saat sedang di drag
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset("assets/images/${getRealImage(dropped)}",
                      width: w(40),
                    ),
                  ),

                  /// 🔥 kalau drag gagal → tetap di tempat
                  onDraggableCanceled: (velocity, offset) {},

                  /// 🔥 TAP = balik ke bawah
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final item = droppedRoads[key];
                        if (item != null) {
                          if (!availableRoads.contains(item)) {
                            availableRoads.add(item);
                          }
                          droppedRoads[key] = null;
                          hasWon = false;
                        }
                      });
                    },
                    child: Image.asset("assets/images/${getRealImage(dropped)}",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
        );
      },
    );
  }

  void nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Materi 12 terbuka!")),
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
                  "Kasih Jalan yang benar supaya bisa sampai ke rumah",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sp(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h(30)),

                /// GRID
                Center(
                  child: Container(
                    width: w(300),
                    height: h(300),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: List.generate(5, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(5, (col) {
                              String? imagePath = gridData[row][col];

                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: (col != 4)
                                            ? Colors.black
                                            : Colors.transparent,
                                      ),
                                      bottom: BorderSide(
                                        color: (row != 4)
                                            ? Colors.black
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: imagePath != null
                                      ? Padding(
                                          padding: EdgeInsets.all(w(5)),
                                          child: Image.asset(
                                            imagePath,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : buildDropBox(row, col),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                SizedBox(height: h(30)),

                /// RUN BUTTON + DRAG ITEM
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// KOSONG (biar ke kanan)
                      const SizedBox(),

                      /// RUN BUTTON
                      GestureDetector(
                        onTap: () {
                          if (droppedCount >= 7) {
                            checkAnswers();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Minimal pasang 7 jalan!"),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(w(10)),
                          decoration: BoxDecoration(
                            color: droppedCount >= 7
                                ? const Color(0xFFFFE082)
                                : Colors.grey,
                            border: Border.all(
                              color: droppedCount >= 7
                                  ? Colors.orangeAccent
                                  : Colors.grey.shade600,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(w(1)),
                          ),
                          child: Opacity(
                            opacity: allDropped ? 1 : 0.5,
                            child: Image.asset(
                              "assets/images/run.png",
                              width: w(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h(10)),

                buildRoadRows(),
              ],
            ),
buildCursor(),
            /// ANIMASI MENANG
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

      /// TOMBOL LANJUT
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.completeMateri(11);

                    // _nextMateri();

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
