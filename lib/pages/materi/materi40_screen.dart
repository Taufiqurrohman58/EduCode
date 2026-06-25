import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi40Screen extends StatefulWidget {
  const Materi40Screen({super.key});

  @override
  State<Materi40Screen> createState() => _Materi40ScreenState();
}

class _Materi40ScreenState extends State<Materi40Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// ===========================
  /// HINT CURSOR
  /// ===========================

  final List<Map<String, dynamic>> hintOrder = [
    {"row": 1, "answer": "BULAT"},
    {"row": 2, "answer": "SAYUR"},
    {"row": 3, "answer": "BUAH"},
  ];

  int cursorIndex = 0;

  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  final Map<String, GlobalKey> optionKeys = {
    "1_BULAT": GlobalKey(),
    "2_SAYUR": GlobalKey(),
    "3_BUAH": GlobalKey(),
  };

  /// JAWABAN BENAR
  final Map<int, String> correctAnswers = {
    1: "BULAT",
    2: "SAYUR",
    3: "BUAH",
  };

  /// PILIHAN USER
  Map<int, String?> selectedAnswers = {
    1: null,
    2: null,
    3: null,
  };

  /// STATUS (correct / wrong)
  Map<int, String?> rowStatus = {
    1: null,
    2: null,
    3: null,
  };

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  bool get allAnswered => selectedAnswers.values.every((e) => e != null);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

  void restartMateri() {
    setState(() {
      selectedAnswers.updateAll((key, value) => null);
      rowStatus.updateAll((key, value) => null);

      cursorIndex = 0;

      hasWon = false;
    });
  }

  Offset getOptionPosition(String key) {
    final context = optionKeys[key]?.currentContext;

    if (context == null) {
      return Offset.zero;
    }

    final box = context.findRenderObject() as RenderBox;

    final pos = box.localToGlobal(Offset.zero);

    return Offset(
      pos.dx + box.size.width / 2 - w(15),
      pos.dy - h(25),
    );
  }

  Widget buildCursor() {
    if (cursorIndex >= hintOrder.length) {
      return const SizedBox();
    }

    final current = hintOrder[cursorIndex];

    String key = "${current["row"]}_${current["answer"]}";

    final pos = getOptionPosition(key);

    if (pos == Offset.zero) {
      return const SizedBox();
    }

    return Positioned(
      top: pos.dy+h(20),
      left: pos.dx,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              _bounceAnim.value,
            ),
            child: Image.asset(
              "assets/images/cursor.png",
              width: w(40),
            ),
          );
        },
      ),
    );
  }

  void autoCheckAnswer() async {
    if (!allAnswered || hasWon) return;

    bool allCorrect = true;

    for (int i = 1; i <= 3; i++) {
      if (selectedAnswers[i] == correctAnswers[i]) {
        rowStatus[i] = 'correct';
      } else {
        rowStatus[i] = 'wrong';
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

      await Future.delayed(const Duration(seconds: 1));

      restartMateri();
    }
  }

  /// OPTION BUTTON
  Widget optionButton(
    int row,
    String text,
  ) {
    bool isSelected = selectedAnswers[row] == text;

    Color borderColor = Colors.transparent;

    if (rowStatus[row] == 'correct' && isSelected) {
      borderColor = Colors.green;
    }

    if (rowStatus[row] == 'wrong' && isSelected) {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        if (cursorIndex >= hintOrder.length) {
          return;
        }

        final current = hintOrder[cursorIndex];

        int expectedRow = current["row"];

        String expectedAnswer = current["answer"];

        if (row != expectedRow || text != expectedAnswer) {
          return;
        }

        setState(() {
          selectedAnswers[row] = text;
          rowStatus[row] = null;

          cursorIndex++;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          autoCheckAnswer,
        );
      },
      child: Stack(
        children: [
          Container(
            key: optionKeys["${row}_$text"],
            padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(6)),
            margin: EdgeInsets.symmetric(vertical: h(4)),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(w(8)),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: sp(16),
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          /// ARROW
          if (isSelected)
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  "assets/images/arrow.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// GAMBAR ITEM
  Widget imageItem(String asset) {
    return Image.asset(
      asset,
      width: w(60),
      height: h(60),
      fit: BoxFit.contain,
    );
  }

  /// ROW
  Widget imageRowWithOption({
    required int rowIndex,
    required List<String> images,
    required List<String> options,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(20)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(30)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(w(14)),
        ),
        child: Row(
          children: [
            /// GAMBAR
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: images.map((img) => imageItem(img)).toList(),
              ),
            ),

            SizedBox(width: w(10)),

            /// OPTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  options.map((opt) => optionButton(rowIndex, opt)).toList(),
            )
          ],
        ),
      ),
    );
  }

  void _nextMateri() async {
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

                SizedBox(height: h(30)),

                Text(
                  "Lingkari pilihan yang berhubungan \n dengan gambar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(40)),

                /// ROW 1
                imageRowWithOption(
                  rowIndex: 1,
                  images: [
                    "assets/images/40/bola1.png",
                    "assets/images/40/bola2.png",
                    "assets/images/40/bola3.png",
                  ],
                  options: ["BULAT", "KOTAK"],
                ),

                SizedBox(height: h(25)),

                /// ROW 2
                imageRowWithOption(
                  rowIndex: 2,
                  images: [
                    "assets/images/40/sayur1.png",
                    "assets/images/40/sayur2.png",
                    "assets/images/40/sayur3.png",
                  ],
                  options: ["BUAH", "SAYUR"],
                ),

                SizedBox(height: h(25)),

                /// ROW 3
                imageRowWithOption(
                  rowIndex: 3,
                  images: [
                    "assets/images/40/buah1.png",
                    "assets/images/40/buah2.png",
                    "assets/images/40/buah3.png",
                  ],
                  options: ["BUAH", "SAYUR"],
                ),
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
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.completeMateri(40);

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
