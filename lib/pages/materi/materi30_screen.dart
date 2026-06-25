import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi30Screen extends StatefulWidget {
  const Materi30Screen({super.key});

  @override
  State<Materi30Screen> createState() => _Materi30ScreenState();
}

class _Materi30ScreenState extends State<Materi30Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// JAWABAN BENAR
  final Map<int, String> correctAnswers = {
    1: "Tersandung",
    2: "Cucian basah",
    3: "Nilai ujian jelek",
  };

  Map<int, String?> selected = {
    1: null,
    2: null,
    3: null,
  };

  Map<int, String?> questionStatus = {
    1: null,
    2: null,
    3: null,
  };

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  /// ===========================
  /// HINT CURSOR
  /// ===========================

  final List<String> hintOrder = [
    "Tersandung",
    "Cucian basah",
    "Nilai ujian jelek",
  ];

  int cursorIndex = 0;

  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  final Map<String, GlobalKey> answerKeys = {
    "Tersandung": GlobalKey(),
    "Cucian basah": GlobalKey(),
    "Nilai ujian jelek": GlobalKey(),
  };

  bool get allAnswered => selected.values.every((e) => e != null);

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

  Offset getAnswerPosition(String label) {
    final context = answerKeys[label]?.currentContext;

    if (context == null) return Offset.zero;

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

    final targetLabel = hintOrder[cursorIndex];

    final pos = getAnswerPosition(targetLabel);

    if (pos == Offset.zero) {
      return const SizedBox();
    }

    return Positioned(
      top: pos.dy + h(35),
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

  void restartMateri() {
    setState(() {
      selected = {1: null, 2: null, 3: null};
      questionStatus = {1: null, 2: null, 3: null};

      cursorIndex = 0;

      hasWon = false;
    });
  }

  void autoCheckAnswers() async {
    if (!allAnswered || hasWon) return;

    bool allCorrect = true;

    for (int i = 1; i <= 3; i++) {
      if (selected[i] == correctAnswers[i]) {
        questionStatus[i] = 'correct';
      } else {
        questionStatus[i] = 'wrong';
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

  /// OPTION
  Widget conditionOption({
    required int index,
    required String image,
    required String label,
  }) {
    bool isSelected = selected[index] == label;
    bool isCorrect = correctAnswers[index] == label;

    Color borderColor = Colors.transparent;

    if (isSelected && questionStatus[index] == 'correct') {
      borderColor = Colors.green;
    }

    if (isSelected && questionStatus[index] == 'wrong') {
      borderColor = isCorrect ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () {
        if (cursorIndex >= hintOrder.length) {
          return;
        }

        final expectedLabel = hintOrder[cursorIndex];

        if (label != expectedLabel) {
          return;
        }

        setState(() {
          selected[index] = label;

          questionStatus[index] = null;

          cursorIndex++;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          autoCheckAnswers,
        );
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                key: answerKeys[label],
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 3),
                  borderRadius: BorderRadius.circular(w(12)),
                ),
                child: Image.asset(
                  image,
                  width: w(80),
                  height: h(80),
                ),
              ),
              if (isSelected)
                Image.asset(
                  "assets/images/arrow.png",
                  width: w(80),
                  height: h(80),
                ),
            ],
          ),
          SizedBox(height: h(6)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sp(14),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget optionRow(List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(top: h(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }

  Widget conditionBlock({
    required int index,
    required String question,
    required List<Widget> options,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h(14)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: w(20)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question,
                style: TextStyle(fontSize: sp(16)),
              ),
            ),
          ),
          SizedBox(height: h(10)),
          optionRow(options),
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

                Text(
                  "Lingkari kondisi yang sesuai",
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(10)),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w(14)),
                      child: Column(
                        children: [
                          conditionBlock(
                            index: 1,
                            question: "Jika berjalan tidak hati-hati, maka:",
                            options: [
                              conditionOption(
                                index: 1,
                                image: "assets/images/30/kesandung.png",
                                label: "Tersandung",
                              ),
                              conditionOption(
                                index: 1,
                                image: "assets/images/30/ngantuk.png",
                                label: "Ngantuk",
                              ),
                              conditionOption(
                                index: 1,
                                image: "assets/images/30/gatal.png",
                                label: "Gatal",
                              ),
                            ],
                          ),
                          conditionBlock(
                            index: 2,
                            question: "Jika hujan, maka:",
                            options: [
                              conditionOption(
                                index: 2,
                                image: "assets/images/30/cucian_basah.png",
                                label: "Cucian basah",
                              ),
                              conditionOption(
                                index: 2,
                                image: "assets/images/30/lapar.png",
                                label: "Lapar",
                              ),
                              conditionOption(
                                index: 2,
                                image: "assets/images/30/haus.png",
                                label: "Haus",
                              ),
                            ],
                          ),
                          conditionBlock(
                            index: 3,
                            question: "Jika tidak belajar, maka:",
                            options: [
                              conditionOption(
                                index: 3,
                                image: "assets/images/30/kotor.png",
                                label: "Kotor",
                              ),
                              conditionOption(
                                index: 3,
                                image: "assets/images/30/nilai_ujian_jelek.png",
                                label: "Nilai ujian jelek",
                              ),
                              conditionOption(
                                index: 3,
                                image: "assets/images/30/tidur.png",
                                label: "Tidur",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    await DBHive.completeMateri(30);

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
