import 'package:flutter/material.dart';
import '../widgets/keyboard_koordinat2.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi33Screen extends StatefulWidget {
  const Materi33Screen({super.key});

  @override
  State<Materi33Screen> createState() => _Materi33ScreenState();
}

class _Materi33ScreenState extends State<Materi33Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// INPUT USER
  String userInput = "";

  /// JAWABAN (Cherry di B2)
  final String answer = "D4";

  /// MATRIX 6x5
  final List<List<String>> gridData = const [
    [
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
    ],
    [
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
    ],
    [
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
    ],
    [
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/cherry.png",
      "assets/images/apple.png",
    ],
    [
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
    ],
    [
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
      "assets/images/apple.png",
    ],
  ];

  final List<String> rowLabels = const ["A", "B", "C", "D", "E", "F"];
  final List<String> colLabels = const ["1", "2", "3", "4", "5"];

  bool isCorrect = false;
  String? lastStatus; // "correct" / "wrong"

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  final List<String> hintOrder = ['D', '4'];

  int cursorIndex = 0;

  final Map<String, GlobalKey> keyMap = {
    for (var k in ['1', '2', '3', '4', '5', 'A', 'B', 'C', 'D', 'E', 'F'])
      k: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
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

  /// HANDLE INPUT DARI KEYBOARD
  void handleInput(String key) {
    setState(() {
      if (key == '←') return;

      if (cursorIndex >= hintOrder.length) return;

      String expectedKey = hintOrder[cursorIndex];

      if (key.toUpperCase() != expectedKey) {
        return;
      }

      userInput += key.toUpperCase();

      cursorIndex++;
    });

    autoCheckAnswer();
  }

  void autoCheckAnswer() async {
    if (userInput.length < 2) return;

    bool correctAnswer = userInput == answer;

    setState(() {
      isCorrect = correctAnswer;
      lastStatus = correctAnswer ? "correct" : "wrong";
    });

    if (correctAnswer) {
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

      restart();
    }
  }

  void restart() {
    setState(() {
      userInput = "";
      isCorrect = false;
      lastStatus = null;
      cursorIndex = 0;
    });
  }

  Offset getKeyPosition(String key) {
    final context = keyMap[key]?.currentContext;

    if (context == null) return Offset.zero;

    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    return Offset(
      position.dx + box.size.width / 2 - w(5),
      position.dy - h(10),
    );
  }

  Widget buildKeyboardCursor() {
    if (cursorIndex >= hintOrder.length) {
      return const SizedBox();
    }

    String currentKey = hintOrder[cursorIndex];

    final pos = getKeyPosition(currentKey);

    if (pos == Offset.zero) {
      return const SizedBox();
    }

    return Positioned(
      top: pos.dy,
      left: pos.dx,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnim.value),
            child: Image.asset(
              'assets/images/cursor.png',
              width: w(35),
            ),
          );
        },
      ),
    );
  }

  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi 2 berhasil terbuka!')),
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
                      color: const Color(0xFFAC4616),
                      alignment: Alignment.center,
                      child: Text(
                        'DEBUGGING',
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

                /// ⬇️ BAGIAN INI YANG DIUBAH
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: h(30)),

                        /// GRID + LABEL
                        Center(
                          child: Column(
                            children: [
                              /// ANGKA 1-5
                              Row(
                                children: [
                                  SizedBox(width: w(30)),
                                  ...List.generate(5, (index) {
                                    return SizedBox(
                                      width: w(60),
                                      child: Center(
                                        child: Text(
                                          colLabels[index],
                                          style: TextStyle(
                                            fontSize: sp(16),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),

                              SizedBox(height: h(5)),

                              /// GRID + HURUF
                              Row(
                                children: [
                                  /// LABEL A-F
                                  Column(
                                    children: List.generate(6, (row) {
                                      return SizedBox(
                                        height: h(60),
                                        width: w(30),
                                        child: Center(
                                          child: Text(
                                            rowLabels[row],
                                            style: TextStyle(
                                              fontSize: sp(16),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),

                                  /// GRID 6x5
                                  Container(
                                    width: w(300),
                                    height: h(360),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Column(
                                      children: List.generate(6, (row) {
                                        return Expanded(
                                          child: Row(
                                            children: List.generate(5, (col) {
                                              String imagePath =
                                                  gridData[row][col];

                                              return Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      right: BorderSide(
                                                        color: col != 4
                                                            ? Colors.black
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                      bottom: BorderSide(
                                                        color: row != 5
                                                            ? Colors.black
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(w(10)),
                                                    child: Image.asset(
                                                      imagePath,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h(16)),

                        Padding(
                          padding: EdgeInsets.all(w(10)),
                          child: Text(
                            'Titik koordinat gambar yang berbeda:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: sp(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        /// INPUT DISPLAY
                        SizedBox(
                          width: w(280),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: Text(
                              userInput,
                              style: TextStyle(
                                fontSize: sp(22),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: lastStatus == null
                                    ? Colors.black
                                    : (isCorrect ? Colors.green : Colors.red),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: h(20)),
                      ],
                    ),
                  ),
                ),

                /// KEYBOARD (tetap di bawah)
                KeyboardKoordinat(
                  onKeyTap: handleInput,
                  keyMap: keyMap,
                ),
              ],
            ),
            buildKeyboardCursor(),
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

      /// BUTTON LANJUT
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.completeMateri(33);

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
