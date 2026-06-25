import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';
import '../widgets/keyboard_number.dart';

class Materi3Screen extends StatefulWidget {
  const Materi3Screen({super.key});

  @override
  State<Materi3Screen> createState() => _Materi3ScreenState();
}

class _Materi3ScreenState extends State<Materi3Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  // setiap baris hanya membutuhkan 1 string (maks 2 digit)
  final List<String> userInputs = List.filled(5, '');
  List<bool> rowCorrect = [false, false, false, false, false];

  String? lastCheckedStatus; // null = belum dicek, "correct" / "wrong"
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  int activeRow = 0; // baris yang sedang aktif menerima input

  final Map<String, GlobalKey> keyMap = {
  for (var k in ['1','2','3','4','5','6','7','8','9','0'])
    k: GlobalKey(),
};

int cursorIndex = 0;

late Animation<double> _bounceAnim;

final List<String> hintOrder = [
  '1','0',
  '1','2',
  '1','2',
  '1','1',
  '1','1',
];

  // Mapping angka bola
  final Map<String, String> correctMapping = {
    'ball1.png': '1',
    'ball2.png': '2',
    'ball3.png': '3',
    'ball4.png': '4',
    'ball5.png': '5',
    'ball6.png': '6',
  };

  final List<List<String>> questionBalls = [
    ["ball4.png", "ball2.png", "ball5.png"],
    ["ball5.png", "ball3.png", "ball2.png"],
    ["ball6.png", "ball5.png", "ball4.png"],
    ["ball3.png", "ball2.png", "ball6.png"],
    ["ball4.png", "ball6.png", "ball5.png"],
  ];

  late AnimationController _controller;

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

  String correctSum(List<String> balls) {
    int total = 0;
    for (var b in balls) {
      total += int.parse(correctMapping[b]!);
    }
    return total.toString();
  }

  Future<void> showResultDialog(bool isCorrect) async {
    setState(() {
      lastCheckedStatus = isCorrect ? "correct" : "wrong";
      if (isCorrect) {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      }
    });

    if (isCorrect) {
      await AudioManager().playEffect('sounds/benar.mp3');
      // beri waktu melihat animasi
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        showWin = false;
      });
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      // tunggu sebentar sebelum restart (user mendengar suara salah)
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void autoCheckAnswers() async {
    // cek semua baris sudah terisi 2 digit
    for (int r = 0; r < userInputs.length; r++) {
      if (userInputs[r].length < 2) return;
    }

    bool allCorrect = true;

    for (int r = 0; r < userInputs.length; r++) {
      String correct = correctSum(questionBalls[r]);
      bool ok = userInputs[r] == correct;
      rowCorrect[r] = ok;
      if (!ok) allCorrect = false;
    }

    // trigger UI warna (lastCheckedStatus diatur di showResultDialog)
    setState(() {});

    if (allCorrect) {
      hasWon = true;
      await showResultDialog(true);
      setState(() {}); // refresh untuk munculkan FAB
    } else {
      await showResultDialog(false);
      // restart setelah suara salah + delay di showResultDialog
      restartMateri();
    }
  }

void restartMateri() {
  setState(() {
    for (int r = 0; r < userInputs.length; r++) {
      userInputs[r] = '';
      rowCorrect[r] = false;
    }

    cursorIndex = 0;

    lastCheckedStatus = null;
    hasWon = false;
    showWin = false;
    activeRow = 0;
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

void handleInput(String key) {
  setState(() {
    if (key == '←') {
      return;
    }

    if (cursorIndex >= hintOrder.length) return;

    String expectedKey = hintOrder[cursorIndex];

    if (key != expectedKey) {
      return;
    }

    if (userInputs[activeRow].length < 2) {
      userInputs[activeRow] += key;

      cursorIndex++;

      if (userInputs[activeRow].length == 2 &&
          activeRow < userInputs.length - 1) {
        activeRow++;
      }
    }
  });

  autoCheckAnswers();
}

  // UI helpers
  Widget ball(String name) {
    return SizedBox(
      width: w(40),
      height: h(40),
      child: Image.asset("assets/images/$name"),
    );
  }

  Widget answerBox(int rowIndex) {
  Color borderColor = Colors.black;
  double borderWidth = 1.5;

  // hanya tampilkan aktif (biru) kalau BELUM dicek
  if (lastCheckedStatus == null && rowIndex == activeRow) {
    borderColor = Colors.blue;
    borderWidth = 2.5;
  }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: w(70),
      height: h(45),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white, // tetap putih (tidak berubah)
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius:
            BorderRadius.circular(w(6)), // biar lebih bagus (optional)
      ),
      child: Text(
        userInputs[rowIndex],
        style: TextStyle(
          fontSize: sp(20),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget sumRow(List<String> balls, int index) {
    return GestureDetector(
      onTap: () {
        // pilih baris untuk edit manual
        setState(() {
          activeRow = index;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w(26)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ball(balls[0]),
            SizedBox(width: w(6)),
            Text("+", style: TextStyle(fontSize: sp(22))),
            SizedBox(width: w(6)),
            ball(balls[1]),
            SizedBox(width: w(6)),
            Text("+", style: TextStyle(fontSize: sp(22))),
            SizedBox(width: w(6)),
            ball(balls[2]),
            SizedBox(width: w(14)),
            Text("=", style: TextStyle(fontSize: sp(22))),
            SizedBox(width: w(14)),
            answerBox(index),
          ],
        ),
      ),
    );
  }

  Widget ballLabel(String assetName, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: w(36),
          height: h(36),
          child: Image.asset('assets/images/$assetName', fit: BoxFit.contain),
        ),
        SizedBox(height: h(6)),
        Text(label, style: TextStyle(fontSize: sp(16))),
      ],
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
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFF45B56B),
                      alignment: Alignment.center,
                      child: Text(
                        'ENCODE & DECODE',
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
                SizedBox(height: h(18)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(18)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ballLabel('ball1.png', '1'),
                      ballLabel('ball2.png', '2'),
                      ballLabel('ball3.png', '3'),
                      ballLabel('ball4.png', '4'),
                      ballLabel('ball5.png', '5'),
                      ballLabel('ball6.png', '6'),
                    ],
                  ),
                ),
                SizedBox(height: h(18)),
                Padding(
                  padding: EdgeInsets.all(w(20)),
                  child: Text(
                    'Jumlahkan dengan tepat',
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(questionBalls.length, (i) {
                      return sumRow(questionBalls[i], i);
                    }),
                  ),
                ),
                NumberKeyboard(onKeyTap: handleInput, keyMap:keyMap),
              ],
            ),
            buildKeyboardCursor(),
            if (showWin && winAnimasi != null)
              Center(
                child: Lottie.asset(
                  winAnimasi!,
                  width: w(250),
                  height: w(250),
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
                    await DBHive.completeMateri(3);

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
