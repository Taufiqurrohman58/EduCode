import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi18Screen extends StatefulWidget {
  const Materi18Screen({super.key});

  @override
  State<Materi18Screen> createState() => _Materi18ScreenState();
}

class _Materi18ScreenState extends State<Materi18Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  static const String imagePath = "assets/images/18/18.png";

  Color? selectedColor;

  late List<List<Color?>> grids;
  late List<List<bool>> isEditable;

  /// ================= MAPPING JAWABAN =================
  final List<List<Color>> correctPairs = [
    [Colors.blue, Colors.yellow], // row 1 baru
    [Colors.pink, Colors.purple], // row 2 baru
    [Colors.red], // row 3 baru
    [Colors.pink], // row 4 baru
    [Colors.green, Colors.red], // row 5 baru
  ];

  final List<HintStep> hintSteps = [
    // row 0
    HintStep(color: Colors.blue, row: 0, col: 1),
    HintStep(color: Colors.yellow, row: 0, col: 2),

    // row 1
    HintStep(color: Colors.pink, row: 1, col: 0),
    HintStep(color: Colors.purple, row: 1, col: 1),

    // row 2
    HintStep(color: Colors.red, row: 2, col: 5),

    // row 3
    HintStep(color: Colors.pink, row: 3, col: 4),

    // row 4
    HintStep(color: Colors.green, row: 4, col: 4),
    HintStep(color: Colors.red, row: 4, col: 5),
  ];

  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;

  late Animation<double> _bounceAnim;

  int currentStep = 0;

  bool colorSelectedCorrectly = false;

  final Map<String, GlobalKey> circleKeys = {};

  final Map<Color, GlobalKey> colorKeys = {
    Colors.red: GlobalKey(),
    Colors.green: GlobalKey(),
    Colors.yellow: GlobalKey(),
    Colors.blue: GlobalKey(),
    Colors.pink: GlobalKey(),
    Colors.purple: GlobalKey(),
  };

  /// ================= INIT =================
  void initGameData() {
    grids = [
      [Colors.yellow, null, null, Colors.blue, Colors.yellow, Colors.blue],
      [null, null, Colors.pink, Colors.purple, Colors.pink, Colors.purple],
      [
        Colors.yellow,
        Colors.green,
        Colors.red,
        Colors.yellow,
        Colors.green,
        null
      ],
      [
        Colors.blue,
        Colors.pink,
        Colors.purple,
        Colors.blue,
        null,
        Colors.purple
      ],
      [Colors.green, Colors.red, Colors.green, Colors.red, null, null],
    ];

    isEditable =
        grids.map((row) => row.map((c) => c == null).toList()).toList();

    circleKeys.clear();

    for (int r = 0; r < grids.length; r++) {
      for (int c = 0; c < grids[r].length; c++) {
        if (isEditable[r][c]) {
          circleKeys["$r-$c"] = GlobalKey();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initGameData();

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

  /// ================= CHECK =================
  bool get allFilled {
    for (int r = 0; r < grids.length; r++) {
      for (int c = 0; c < grids[r].length; c++) {
        if (isEditable[r][c] && grids[r][c] == null) return false;
      }
    }
    return true;
  }

  /// ================= RESTART =================
  void restartMateri() {
    setState(() {
      initGameData();

      hasWon = false;

      currentStep = 0;
      colorSelectedCorrectly = false;

      selectedColor = null;
    });
  }

  Offset getCirclePosition(int row, int col) {
    final context = circleKeys["$row-$col"]?.currentContext;

    if (context == null) return Offset.zero;

    final box = context.findRenderObject() as RenderBox;

    final pos = box.localToGlobal(Offset.zero);

    return Offset(
      pos.dx + box.size.width / 2 - w(15),
      pos.dy - h(30),
    );
  }

  Offset getColorPosition(Color color) {
    final context = colorKeys[color]?.currentContext;

    if (context == null) return Offset.zero;

    final box = context.findRenderObject() as RenderBox;

    final pos = box.localToGlobal(Offset.zero);

    return Offset(
      pos.dx + box.size.width / 2 - w(15),
      pos.dy - h(30),
    );
  }

  Widget buildCursor() {
    if (currentStep >= hintSteps.length) {
      return const SizedBox();
    }

    final step = hintSteps[currentStep];

    Offset pos;

    if (!colorSelectedCorrectly) {
      pos = getColorPosition(step.color);
    } else {
      pos = getCirclePosition(step.row, step.col);
    }

    if (pos == Offset.zero) {
      return const SizedBox();
    }

    return Positioned(
      top: pos.dy + h(20),
      left: pos.dx + w(5),
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnim.value),
            child: Image.asset(
              "assets/images/cursor.png",
              width: w(40),
            ),
          );
        },
      ),
    );
  }

  /// ================= RESULT =================
  Future<void> showResultDialog(bool isCorrect) async {
    if (isCorrect) {
      setState(() {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      });

      await AudioManager().playEffect('sounds/benar.mp3');
      await Future.delayed(const Duration(seconds: 3));

      setState(() => showWin = false);
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      await Future.delayed(const Duration(seconds: 2));
      restartMateri();
    }
  }

  /// ================= AUTO CHECK =================
  void autoCheckAnswers() async {
    if (!allFilled || hasWon) return;

    bool allCorrect = true;

    for (int r = 0; r < grids.length; r++) {
      final expected = correctPairs[r];

      for (int c = 0; c < grids[r].length; c++) {
        if (!isEditable[r][c]) continue;

        if (!expected.contains(grids[r][c])) {
          allCorrect = false;
        }
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

  /// ================= CIRCLE ITEM =================
  Widget circleItem(int row, int col) {
    final color = grids[row][col];

    return GestureDetector(
      onTap: isEditable[row][col]
          ? () {
              if (currentStep >= hintSteps.length) {
                return;
              }

              if (!colorSelectedCorrectly) {
                return;
              }

              final step = hintSteps[currentStep];

              if (row != step.row || col != step.col) {
                return;
              }

              setState(() {
                grids[row][col] = selectedColor;

                currentStep++;

                colorSelectedCorrectly = false;

                selectedColor = null;
              });

              Future.delayed(
                const Duration(milliseconds: 300),
                autoCheckAnswers,
              );
            }
          : null,
      child: Container(
        key: isEditable[row][col] ? circleKeys["$row-$col"] : null,
        width: w(40),
        height: h(40),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? Colors.transparent,
          border: Border.all(
            color: Colors.black,
            width: 1.5, // 🔥 samakan dengan UI contoh
          ),
        ),
      ),
    );
  }

  Widget buildCircleRow(int rowIndex) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        6,
        (index) => circleItem(rowIndex, index),
      ),
    );
  }

  /// ================= IMAGE =================
  Widget imageItem() {
    return SizedBox(
      width: w(55),
      height: h(55),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget rowCircleThenImage(int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildCircleRow(rowIndex),
        imageItem(),
      ],
    );
  }

  Widget rowImageThenCircle(int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        imageItem(),
        buildCircleRow(rowIndex),
      ],
    );
  }

  /// ================= COLOR PICKER =================
  Widget colorPicker(
    Color color,
    GlobalKey key,
  ) {
    bool isSelected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        if (currentStep >= hintSteps.length) {
          return;
        }

        final expectedColor = hintSteps[currentStep].color;

        if (color != expectedColor) {
          return;
        }

        setState(() {
          selectedColor = color;

          colorSelectedCorrectly = true;
        });
      },
      child: AnimatedContainer(
        key: key,
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 45 : 40,
        height: isSelected ? 45 : 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.7),
                spreadRadius: 2,
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black,
              width: isSelected ? 4 : 2,
            ),
          ),
        ),
      ),
    );
  }

  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi 19 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// ================= UI =================
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

                SizedBox(height: h(30)),

                const Text("Warnai lingkaran sesuai pola"),

                SizedBox(height: h(30)),

                rowCircleThenImage(0),
                SizedBox(height: h(20)),

                rowImageThenCircle(1),
                SizedBox(height: h(20)),

                rowCircleThenImage(2),
                SizedBox(height: h(20)),

                rowImageThenCircle(3),
                SizedBox(height: h(20)),

                rowCircleThenImage(4),

                const Spacer(),

                /// COLOR PICKER
                Container(
                  height: h(80),
                  color: const Color(0xFFF7F7F7),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        colorPicker(
                          Colors.red,
                          colorKeys[Colors.red]!,
                        ),
                        SizedBox(width: w(10)),
                        colorPicker(
                          Colors.green,
                          colorKeys[Colors.green]!,
                        ),
                        SizedBox(width: w(10)),
                        colorPicker(
                          Colors.yellow,
                          colorKeys[Colors.yellow]!,
                        ),
                        SizedBox(width: w(10)),
                        colorPicker(
                          Colors.blue,
                          colorKeys[Colors.blue]!,
                        ),
                        SizedBox(width: w(10)),
                        colorPicker(
                          Colors.pink,
                          colorKeys[Colors.pink]!,
                        ),
                        SizedBox(width: w(10)),
                        colorPicker(
                          Colors.purple,
                          colorKeys[Colors.purple]!,
                        ),
                      ],
                    ),
                  ),
                ),
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
                    await DBHive.completeMateri(18);

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

class HintStep {
  final Color color;
  final int row;
  final int col;

  HintStep({
    required this.color,
    required this.row,
    required this.col,
  });
}
