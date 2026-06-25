import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi31Screen extends StatefulWidget {
  const Materi31Screen({super.key});

  @override
  State<Materi31Screen> createState() => _Materi31ScreenState();
}

class _Materi31ScreenState extends State<Materi31Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// =============================
  /// DATA GRID (TETAP)
  /// =============================
  final List<List<String?>> gridData = const [
    [
      "assets/images/31/orang.jpg",
      "assets/images/31/jalan_a.png",
      "assets/images/31/jalan_c.png",
      "assets/images/31/pohon.jpg",
    ],
    [
      "assets/images/31/pohon.jpg",
      "assets/images/31/pohon.jpg",
      "assets/images/31/jalan_b.png",
      "assets/images/31/jalan_c.png",
    ],
    [
      "assets/images/31/pohon.jpg",
      "assets/images/31/gajah.png",
      "assets/images/31/pohon.jpg",
      "assets/images/31/jalan_b.png",
    ],
    [
      "assets/images/31/pohon.jpg",
      "assets/images/31/pohon.jpg",
      "assets/images/31/pohon.jpg",
      "assets/images/31/rumah.jpg",
    ],
  ];

  final List<String> rowLabels = const ["A", "B", "C", "D"];
  final List<String> colLabels = const ["1", "2", "3", "4"];

  /// =============================
  /// JAWABAN
  /// =============================
  final List<String> textOptions = ["A2", "C1", "B3"];
  final List<String> imageOptions = [
    "assets/images/31/jalan_a.png",
    "assets/images/31/jalan_d.png",
    "assets/images/31/jalan_e.png",
  ];

  final String correctText = "B3";
  final String correctImage = "assets/images/31/jalan_d.png";

  /// =============================
  /// PETUNJUK CURSOR
  /// =============================
  final List<String> hintOrder = [
    "B3",
    "assets/images/31/jalan_d.png",
  ];

  int cursorIndex = 0;

  final Map<String, GlobalKey> itemKeys = {
    "A2": GlobalKey(),
    "C1": GlobalKey(),
    "B3": GlobalKey(),
    "assets/images/31/jalan_a.png": GlobalKey(),
    "assets/images/31/jalan_d.png": GlobalKey(),
    "assets/images/31/jalan_e.png": GlobalKey(),
  };

  String? selectedText;
  String? selectedImage;

  Map<String, String?> textStatus = {};
  Map<String, String?> imageStatus = {};

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  bool get allSelected => selectedText != null && selectedImage != null;
  late AnimationController _controller;
  late Animation<double> _bounceAnim;

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

  /// =============================
  /// RESET
  /// =============================
  void restartMateri() {
    setState(() {
      selectedText = null;
      selectedImage = null;

      textStatus.clear();
      imageStatus.clear();

      cursorIndex = 0;

      hasWon = false;
    });
  }

  Offset getItemPosition(String key) {
    final context = itemKeys[key]?.currentContext;

    if (context == null) return Offset.zero;

    final box = context.findRenderObject() as RenderBox;

    final position = box.localToGlobal(Offset.zero);

    return Offset(
      position.dx + box.size.width / 2 - w(15),
      position.dy - h(25),
    );
  }

  Widget buildCursor() {
    if (cursorIndex >= hintOrder.length) {
      return const SizedBox();
    }

    final target = hintOrder[cursorIndex];

    final pos = getItemPosition(target);

    if (pos == Offset.zero) {
      return const SizedBox();
    }

    return Positioned(
      top: pos.dy + h(20),
      left: pos.dx + w(10),
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

  /// =============================
  /// AUTO CHECK
  /// =============================
  void autoCheckAnswer() async {
    if (!allSelected || hasWon) return;

    bool allCorrect = true;

    /// TEXT CHECK
    for (var text in textOptions) {
      if (text == selectedText && text == correctText) {
        textStatus[text] = 'correct';
      } else if (text == selectedText) {
        textStatus[text] = 'wrong';
        allCorrect = false;
      }
    }

    /// IMAGE CHECK
    for (var img in imageOptions) {
      if (img == selectedImage && img == correctImage) {
        imageStatus[img] = 'correct';
      } else if (img == selectedImage) {
        imageStatus[img] = 'wrong';
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

  /// =============================
  /// WIDGET TEXT
  /// =============================
  Widget textItem(String text) {
    bool isSelected = selectedText == text;

    Color borderColor = Colors.transparent;

    if (isSelected && textStatus[text] == 'correct') {
      borderColor = Colors.green;
    } else if (isSelected && textStatus[text] == 'wrong') {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        if (cursorIndex >= hintOrder.length) return;

        final expected = hintOrder[cursorIndex];

        if (text != expected) return;

        setState(() {
          selectedText = text;
          textStatus[text] = null;

          cursorIndex++;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          autoCheckAnswer,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            key: itemKeys[text],
            width: w(45),
            height: h(45),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(w(8)),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: sp(18)),
            ),
          ),
          if (isSelected)
            Image.asset(
              "assets/images/arrow.png",
              width: w(40),
              height: h(40),
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }

  /// =============================
  /// WIDGET IMAGE
  /// =============================
  Widget imageItem(String path) {
    bool isSelected = selectedImage == path;

    Color borderColor = Colors.black;

    if (isSelected && imageStatus[path] == 'correct') {
      borderColor = Colors.green;
    } else if (isSelected && imageStatus[path] == 'wrong') {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        if (cursorIndex >= hintOrder.length) return;

        final expected = hintOrder[cursorIndex];

        if (path != expected) return;

        setState(() {
          selectedImage = path;
          imageStatus[path] = null;

          cursorIndex++;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          autoCheckAnswer,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            key: itemKeys[path],
            width: w(70),
            height: h(70),
            margin: EdgeInsets.symmetric(horizontal: w(8)),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Image.asset(path, fit: BoxFit.cover),
          ),
          if (isSelected)
            Image.asset(
              "assets/images/arrow.png",
              width: w(70),
              height: h(70),
              fit: BoxFit.contain,
            ),
        ],
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

                SizedBox(height: h(30)),

                /// ================= GRID =================
                Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: w(30)),
                          ...List.generate(4, (index) {
                            return SizedBox(
                              width: w(70),
                              child: Center(
                                child: Text(
                                  colLabels[index],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: h(5)),
                      Row(
                        children: [
                          Column(
                            children: List.generate(4, (row) {
                              return SizedBox(
                                height: h(70),
                                width: w(30),
                                child: Center(child: Text(rowLabels[row])),
                              );
                            }),
                          ),
                          Container(
                            width: w(300),
                            height: h(300),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              children: List.generate(4, (row) {
                                return Expanded(
                                  child: Row(
                                    children: List.generate(4, (col) {
                                      return Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            gridData[row][col]!,
                                            fit: BoxFit.contain,
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

                SizedBox(height: h(20)),

                /// ================= TEXT =================
                const Text("Lingkari jalan yang salah"),

                SizedBox(height: h(10)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: textOptions.map((e) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: w(16)),
                      child: textItem(e),
                    );
                  }).toList(),
                ),

                SizedBox(height: h(5)),

                /// ================= IMAGE =================
                const Text("Lingkari jalan yang seharusnya"),

                SizedBox(height: h(5)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageOptions.map((e) => imageItem(e)).toList(),
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
                    await DBHive.completeMateri(31);

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
