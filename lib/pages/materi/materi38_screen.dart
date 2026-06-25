import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';
import '../widgets/keyboard_number.dart';

class Materi38Screen extends StatefulWidget {
  const Materi38Screen({super.key});

  @override
  State<Materi38Screen> createState() => _Materi38ScreenState();
}
class _Materi38ScreenState extends State<Materi38Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// TOTAL ADA 6 INPUT (3 BOX x 2)
  final List<String> userInputs = List.filled(6, '');
  List<bool> inputCorrect = List.filled(6, false);

  int activeIndex = 0;

  String? lastCheckedStatus;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;
late Animation<double> _bounce;

  /// PETUNJUK
int hintIndex = 0;

final Map<String, GlobalKey> keyMap = {
  for (var k in ['0','1','2','3','4','5','6','7','8','9'])
    k: GlobalKey(),
};


final List<String> hintOrder = [
  '3', '3',
  '2', '1',
  '2', '2',
];

  /// JAWABAN
  final List<String> correctAnswers = [
    '3', '3', // box 1
    '2', '1', // box 2
    '2', '2', // box 3
  ];

  /// =========================
  /// HANDLE INPUT
  /// =========================

  void handleInput(String key) {
    setState(() {
      if (key == '←') {
        if (userInputs[activeIndex].isNotEmpty) {
          userInputs[activeIndex] = '';
        } else if (activeIndex > 0) {
          activeIndex--;
          userInputs[activeIndex] = '';
        }
        return;
      }

if (userInputs[activeIndex].isEmpty) {
  userInputs[activeIndex] = key;

  /// jika sesuai petunjuk lanjut
  if (hintIndex < hintOrder.length &&
      key == hintOrder[hintIndex]) {
    hintIndex++;
  }

  if (activeIndex < userInputs.length - 1) {
    activeIndex++;
  }
}
    });

    autoCheck();
  }

@override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  _bounce = Tween<double>(begin: -6, end: 6).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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

  /// =========================
  /// AUTO CHECK
  /// =========================
  void autoCheck() async {
    for (var input in userInputs) {
      if (input.isEmpty) return;
    }

    bool allCorrect = true;

    for (int i = 0; i < userInputs.length; i++) {
      bool ok = userInputs[i] == correctAnswers[i];
      inputCorrect[i] = ok;
      if (!ok) allCorrect = false;
    }

    setState(() {});

    if (allCorrect) {
      hasWon = true;
      await showResult(true);
      setState(() {});
    } else {
      await showResult(false);
      restartMateri();
    }
  }

  /// =========================
  /// RESULT
  /// =========================
  Future<void> showResult(bool isCorrect) async {
    setState(() {
      lastCheckedStatus = isCorrect ? "correct" : "wrong";
      if (isCorrect) {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      }
    });

    if (isCorrect) {
      await AudioManager().playEffect('sounds/benar.mp3');
      await Future.delayed(const Duration(seconds: 3));
      setState(() => showWin = false);
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// =========================
  /// RESET
  /// =========================
  void restartMateri() {
    setState(() {
      for (int i = 0; i < userInputs.length; i++) {
        userInputs[i] = '';
        inputCorrect[i] = false;
      }
      activeIndex = 0;
      lastCheckedStatus = null;
      hasWon = false;
      showWin = false;
    });
  }

Offset getKeyPosition(String key) {
  final context = keyMap[key]?.currentContext;

  if (context == null) {
    return Offset.zero;
  }

  final box = context.findRenderObject() as RenderBox;
  final pos = box.localToGlobal(Offset.zero);

  return Offset(
    pos.dx + box.size.width / 2 - w(8),
    pos.dy - h(15),
  );
}

Widget buildHintCursor() {
  if (hintIndex >= hintOrder.length) {
    return const SizedBox();
  }

  final pos = getKeyPosition(hintOrder[hintIndex]);

  if (pos == Offset.zero) {
    return const SizedBox();
  }

  return Positioned(
    top: pos.dy,
    left: pos.dx,
    child: AnimatedBuilder(
      animation: _bounce,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/cursor.png',
        width: w(35),
      ),
    ),
  );
}
  /// =========================
  /// INPUT BOX (CUSTOM)
  /// =========================
  Widget inputBox(int index) {
    Color borderColor = Colors.black;
    double borderWidth = 1.5;

    if (lastCheckedStatus == null) {
      if (index == activeIndex) {
        borderColor = Colors.blue;
        borderWidth = 2;
      }
    } else {
      borderColor = inputCorrect[index] ? Colors.green : Colors.red;
      borderWidth = 2;
    }

    return GestureDetector(
      onTap: () {
        setState(() => activeIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: w(25),
        height: h(25),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Text(
          userInputs[index],
          style: TextStyle(fontSize: sp(13), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// =========================
  /// QUESTION BOX
  /// =========================
  Widget questionBox(String text, int inputIndex) {
    return Padding(
      padding: EdgeInsets.all(w(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text,
              textAlign: TextAlign.center, style: TextStyle(fontSize: sp(12))),
          SizedBox(height: h(2)),
          inputBox(inputIndex),
        ],
      ),
    );
  }

  /// =========================
  /// MAIN BOX
  /// =========================
  Widget mainBox({
    required String image,
    required String q1,
    required String q2,
    required int index1,
    required int index2,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(20), vertical: h(5)),
      child: Container(
        height: h(150),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 57,
              child: Padding(
                padding: EdgeInsets.all(w(8)),
                child: Image.asset(image),
              ),
            ),
            Container(width: w(2), color: Colors.black),
            Expanded(
              flex: 43,
              child: Column(
                children: [
                  Expanded(child: questionBox(q1, index1)),
                  Container(height: h(2), color: Colors.black),
                  Expanded(child: questionBox(q2, index2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// =========================
  /// BUILD
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
                SizedBox(height: h(15)),
                const Text("Jawab pertanyaan dengan tepat"),
                SizedBox(height: h(10)),
                mainBox(
                  image: "assets/images/es_krim.png",
                  q1: "Total ada berapa es krim ?",
                  q2: "Ada berapa jenis es krim pada gambar ?",
                  index1: 0,
                  index2: 1,
                ),

                  mainBox(
                  image: "assets/images/cat2.png",
                  q1: "Ada berapa kucing ?",
                  q2: "Ada berapa jenis hewan pada gambar ?",
                  index1: 2,
                  index2: 3,
                ),
                                mainBox(
                  image: "assets/images/buah.png",
                  q1: "Ada berapa jeruk ?",
                  q2: "Ada berapa jenis buah pada gambar ?",
                  index1: 4,
                  index2: 5,
                ),
                const Spacer(),
                NumberKeyboard(
  onKeyTap: handleInput,
  keyMap: keyMap,
),
              ],
            ),
            buildHintCursor(),
            if (showWin && winAnimasi != null)
              Center(
                child: Lottie.asset(winAnimasi!, width: w(250), repeat: false),
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
                    await DBHive.completeMateri(38);

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
