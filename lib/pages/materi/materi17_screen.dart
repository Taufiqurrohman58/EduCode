import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi17Screen extends StatefulWidget {
  const Materi17Screen({super.key});

  @override
  State<Materi17Screen> createState() => _Materi17ScreenState();
}

class _Materi17ScreenState extends State<Materi17Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// =========================
  /// JAWABAN BENAR (LOOP)
  final List<String> correctAnswers = [
    "kiwi.png",
    "orange.png",
    "apple.png",
    "pineapple.png",
  ];

  /// =========================
  List<String> availableFruits = [
    "apple.png",
    "kiwi.png",
    "orange.png",
    "pineapple.png",
  ];

  List<String?> dropped = [null, null, null, null];

  int hintStep = 0;

final List<String> hintOrder = [
  "kiwi.png",
  "orange.png",
  "apple.png",
  "pineapple.png",
];

late Animation<double> _cursorAnim;

  late AnimationController _controller;

  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

@override
void initState() {
  super.initState();

  _controller = AnimationController(
    duration: const Duration(milliseconds: 700),
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

  void startCursorAnimation() async {
  while (mounted) {
    await _controller.forward(from: 0);

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    _controller.reset();
  }
}

  bool get allDropped => !dropped.contains(null);

  /// =========================
void restartMateri() {
  setState(() {

    hintStep = 0;

    dropped = [null, null, null, null];

    availableFruits = [
      "apple.png",
      "kiwi.png",
      "orange.png",
      "pineapple.png",
    ];

    hasWon = false;
  });
}



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
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      await Future.delayed(const Duration(seconds: 2));
      restartMateri();
    }
  }

  /// =========================
  void autoCheckAnswers() async {
    if (!allDropped || hasWon) return;

    bool allCorrect = true;

    for (int i = 0; i < dropped.length; i++) {
      if (dropped[i] != correctAnswers[i]) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() {
        hasWon = true;
      });
      _controller.forward(from: 0);
      await showResultDialog(true);
    } else {
      _controller.forward(from: 0);
      await showResultDialog(false);
    }
  }

  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi 18 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// =========================
  Widget imageBox(String image) {
    return Container(
      width: w(55),
      height: h(55),
      margin: EdgeInsets.symmetric(horizontal: w(5)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(w(6)),
        child: Image.asset(image, fit: BoxFit.contain),
      ),
    );
  }

  /// =========================
  Widget emptyBox(int index) {
    final fruit = dropped[index];

    return DragTarget<String>(
     onAcceptWithDetails: (details) {

  final data = details.data;

  if (hintStep >= hintOrder.length) return;

  /// buah yang harus dipilih sekarang
  String expectedFruit = hintOrder[hintStep];

  /// box yang harus diisi sekarang
  int expectedBox = hintStep;

  if (data != expectedFruit || index != expectedBox) {
    return;
  }

  setState(() {

    dropped[index] = data;

    availableFruits.remove(data);

    hintStep++;
  });

  Future.delayed(
    const Duration(milliseconds: 300),
    autoCheckAnswers,
  );
},
      builder: (context, candidateData, rejectedData) {
        Color borderColor = Colors.black;

        return Container(
          width: w(60),
          height: h(55),
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: w(8)),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
          ),
          child: fruit == null
              ? Text(
                  "TEMPEL\nDISINI",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: sp(12)),
                )
              : Draggable<String>(
                  data: fruit,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      "assets/images/$fruit",
                      width: w(60),
                      height: h(60),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      "assets/images/$fruit",
                      width: w(50),
                      height: h(50),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!availableFruits.contains(fruit)) {
                          availableFruits.add(fruit);
                        }
                        dropped[index] = null;
                        hasWon = false;
                      });
                    },
                    child: Image.asset(
                      "assets/images/$fruit",
                      width: w(50),
                      height: h(50),
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// =========================
  Widget patternRow(List<String> images, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...images.map((e) => imageBox(e)),
          emptyBox(index),
        ],
      ),
    );
  }

  /// =========================
  Widget fruitItem(String asset) {
    return Draggable<String>(
      data: asset,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(
          "assets/images/$asset",
          width: w(60),
          height: h(60),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(
          "assets/images/$asset",
          width: w(50),
          height: h(50),
        ),
      ),
      child: Container(
        width: w(70),
        height: h(70),
        margin: EdgeInsets.all(w(6)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.5),
        ),
        child: Center(
          child: Image.asset(
            "assets/images/$asset",
            width: w(50),
            height: h(50),
          ),
        ),
      ),
    );
  }

  /// =========================
  Widget buildFruitRows() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: availableFruits.map((e) => fruitItem(e)).toList(),
    );
  }

  Widget buildCursor() {

  if (hintStep >= hintOrder.length) {
    return const SizedBox();
  }

  String currentFruit = hintOrder[hintStep];

  final fruitPosition = {
    "apple.png": Offset(w(40), h(520)),
    "kiwi.png": Offset(w(120), h(520)),
    "orange.png": Offset(w(210), h(520)),
    "pineapple.png": Offset(w(300), h(520)),
  };

  final boxPosition = {
    0: Offset(w(305), h(175)),
    1: Offset(w(305), h(245)),
    2: Offset(w(305), h(315)),
    3: Offset(w(305), h(385)),
  };

  final start = fruitPosition[currentFruit]!;

  final end = boxPosition[hintStep]!;

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
        top: dy,
        child: Image.asset(
          'assets/images/cursor.png',
          width: w(40),
        ),
      );
    },
  );
}

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
                      color: const Color(0xFF6E64AB),
                      alignment: Alignment.center,
                      child: Text(
                        'LOOPS',
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
                SizedBox(height: h(45)),
                Text(
                  "Gunting dan tempel sesuai pola yang tepat",
                  style: TextStyle(fontSize: sp(16)),
                ),
                SizedBox(height: h(30)),
                patternRow([
                  "assets/images/kiwi.png",
                  "assets/images/strawberry.png",
                  "assets/images/kiwi.png",
                  "assets/images/strawberry.png",
                ], 0),
                patternRow([
                  "assets/images/orange.png",
                  "assets/images/pear.png",
                  "assets/images/orange.png",
                  "assets/images/pear.png",
                ], 1),
                patternRow([
                  "assets/images/apple.png",
                  "assets/images/grape.png",
                  "assets/images/apple.png",
                  "assets/images/grape.png",
                ], 2),
                patternRow([
                  "assets/images/pineapple.png",
                  "assets/images/watermelon.png",
                  "assets/images/pineapple.png",
                  "assets/images/watermelon.png",
                ], 3),
                SizedBox(height: h(30)),
                buildFruitRows(),
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
                    await DBHive.completeMateri(17);

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
