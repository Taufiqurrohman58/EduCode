import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi39Screen extends StatefulWidget {
  const Materi39Screen({super.key});

  @override
  State<Materi39Screen> createState() => _Materi39ScreenState();
}

class _Materi39ScreenState extends State<Materi39Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  Color? selectedColor;

  /// URUTAN PENGERJAAN
  final List<int> hintOrder = [0, 1, 2, 3];

  int cursorIndex = 0;
  bool correctColorSelected = false;
  bool waitingColorSelection = true;

  final Map<int, GlobalKey> circleKeys = {
    0: GlobalKey(),
    1: GlobalKey(),
    2: GlobalKey(),
    3: GlobalKey(),
  };

  final GlobalKey redKey = GlobalKey();
  final GlobalKey greenKey = GlobalKey();

  late Animation<double> _bounceAnim;

  /// STATE LINGKARAN
  List<Color?> circleColors = List.generate(4, (index) => null);

  /// MAPPING BENAR
  final List<Color> correctMapping = [
    Colors.red,
    Colors.green,
    Colors.red,
    Colors.green,
  ];

  late AnimationController _controller;

  String? lastCheckedStatus;
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

  bool get allFilled => !circleColors.contains(null);

  /// RESTART
  void restartMateri() {
    setState(() {
      circleColors = List.generate(4, (index) => null);

      lastCheckedStatus = null;

      hasWon = false;

      cursorIndex = 0;

      correctColorSelected = false;
      waitingColorSelection = true;
      selectedColor = null;
    });
  }

  Offset getCirclePosition(int index) {
    final context = circleKeys[index]?.currentContext;

    if (context == null) return Offset.zero;

    final box = context.findRenderObject() as RenderBox;

    final position = box.localToGlobal(Offset.zero);

    return Offset(
      position.dx + box.size.width / 2 - w(15),
      position.dy - h(35),
    );
  }

  Offset getColorPosition(GlobalKey key) {
    final context = key.currentContext;

    if (context == null) return Offset.zero;

    final box = context.findRenderObject() as RenderBox;

    final position = box.localToGlobal(Offset.zero);

    return Offset(
      position.dx + box.size.width / 2 - w(15),
      position.dy - h(35),
    );
  }

  Widget buildCursor() {
    Offset pos;

    if (waitingColorSelection) {
      final expectedColor = getExpectedColor();

      pos = expectedColor == Colors.red
          ? getColorPosition(redKey)
          : getColorPosition(greenKey);
    } else {
      final targetIndex = hintOrder[cursorIndex];

      pos = getCirclePosition(targetIndex);
    }

    if (pos == Offset.zero) {
      return const SizedBox();
    }

    return Positioned(
      top: pos.dy + h(25),
      left: pos.dx,
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

  Color getExpectedColor() {
    if (cursorIndex >= correctMapping.length) {
      return Colors.red;
    }

    return correctMapping[cursorIndex];
  }

  /// RESULT
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

  /// AUTO CHECK
  void autoCheckAnswers() async {
    if (!allFilled || hasWon) return;

    bool allCorrect = true;

    for (int i = 0; i < circleColors.length; i++) {
      if (circleColors[i] != correctMapping[i]) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() {
        lastCheckedStatus = 'correct';
        hasWon = true;
      });

      _controller.forward(from: 0);
      await showResultDialog(true);
    } else {
      setState(() => lastCheckedStatus = 'wrong');

      _controller.forward(from: 0);
      await showResultDialog(false);
    }
  }

  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi 40 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// LEGEND
  Widget legendItem(String text, Color color) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: sp(16),
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: w(10)),
        Container(
          width: w(40),
          height: h(40),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        )
      ],
    );
  }

  /// CARD
  Widget foodCard(String imagePath, int index) {
    final isCorrect = circleColors[index] != null &&
        circleColors[index] == correctMapping[index];

    Color borderColor = Colors.black;

    if (lastCheckedStatus == 'correct') {
      if (isCorrect) borderColor = Colors.green;
    } else if (lastCheckedStatus == 'wrong') {
      if (circleColors[index] != null) {
        if (isCorrect) {
          borderColor = Colors.green;
        } else {
          borderColor = Colors.red;
        }
      }
    }

    return SizedBox(
      width: w(140),
      height: h(200),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          /// BOX
          Container(
            width: w(140),
            height: h(160),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w(12)),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.all(w(18)),
              child: Center(
                child: SizedBox(
                  width: w(90),
                  height: h(90),
                  child: Image.asset(imagePath),
                ),
              ),
            ),
          ),

          /// CIRCLE
          Positioned(
            bottom: h(12),
            child: GestureDetector(
              onTap: () {
                if (cursorIndex >= hintOrder.length) return;

                final expectedIndex = hintOrder[cursorIndex];

                if (index != expectedIndex) {
                  return;
                }

                if (!correctColorSelected) {
                  return;
                }

                setState(() {
                  circleColors[index] = selectedColor;

                  cursorIndex++;

                  correctColorSelected = false;

                  waitingColorSelection = true;

                  selectedColor = null;
                });

                Future.delayed(
                  const Duration(milliseconds: 300),
                  autoCheckAnswers,
                );
              },
              child: Container(
                key: circleKeys[index],
                width: w(55),
                height: h(55),
                decoration: BoxDecoration(
                  color: circleColors[index] ?? Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// COLOR PICKER
  Widget colorPicker(Color color, GlobalKey key) {
    bool isSelected = selectedColor != null && selectedColor == color;

    return GestureDetector(
      onTap: () {
        if (!waitingColorSelection) {
          return;
        }

        final expectedColor = getExpectedColor();

        if (color != expectedColor) {
          return;
        }

        setState(() {
          selectedColor = color;

          correctColorSelected = true;

          waitingColorSelection = false;
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
              blurRadius: w(8),
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

                SizedBox(height: h(20)),

                const Text("Warnai lingkaran berdasarkan jenisnya"),

                SizedBox(height: h(20)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    legendItem("BUAH", Colors.red),
                    const SizedBox(width: 40),
                    legendItem("SAYUR", Colors.green),
                  ],
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: h(28)),
                    child: Column(
                      children: [
                        SizedBox(height: h(20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            foodCard("assets/images/strawberry.png", 0),
                            foodCard("assets/images/spinach.png", 1),
                          ],
                        ),
                        SizedBox(height: h(20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            foodCard("assets/images/orange.png", 2),
                            foodCard("assets/images/broccoli.png", 3),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /// PICKER
                Container(
                  height: h(70),
                  padding: EdgeInsets.symmetric(horizontal: w(40)),
                  color: const Color(0xFFF7F7F7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      colorPicker(Colors.red, redKey),
                      colorPicker(Colors.green, greenKey),
                    ],
                  ),
                ),
              ],
            ),
            buildCursor(),

            /// ANIMASI
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
                    await DBHive.completeMateri(39);

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
