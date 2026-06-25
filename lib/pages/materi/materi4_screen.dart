import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';
import '../widgets/keyboard_letter.dart';

class Materi4Screen extends StatefulWidget {
  const Materi4Screen({super.key});

  @override
  State<Materi4Screen> createState() => _Materi4ScreenState();
}

class _Materi4ScreenState extends State<Materi4Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  final List<List<String>> correctAnswers = [
    ['B', 'A', 'R', 'U'],
    ['L', 'A', 'R', 'A'],
    ['B', 'E', 'L', 'A'],
    ['R', 'E', 'L', 'A'],
    ['B', 'A', 'L', 'A'],
  ];

  List<bool> rowCorrect = [false, false, false, false, false];

  final List<List<String>> userInputs =
      List.generate(5, (_) => List.filled(4, ''));

  int selectedRow = 0;

  String? lastCheckedStatus;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;
  late AnimationController _controller;

  final Map<String, GlobalKey> keyMap = {
  for (var k in [
    'Q','W','E','R','T','Y','U','I','O','P',
    'A','S','D','F','G','H','J','K','L',
    'Z','X','C','V','B','N','M'
  ])
    k: GlobalKey(),
};

int cursorIndex = 0;

late Animation<double> _bounceAnim;

final List<String> hintOrder = [
  'B','A','R','U',
  'L','A','R','A',
  'B','E','L','A',
  'R','E','L','A',
  'B','A','L','A',
];

@override
void initState() {
  super.initState();

  selectedRow = 0;

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
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        showWin = false;
      });
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> autoCheckAnswers() async {
    bool allFilled = true;
    for (int r = 0; r < 5; r++) {
      if (userInputs[r].any((e) => e.isEmpty)) {
        allFilled = false;
        break;
      }
    }

    if (!allFilled) return;

    bool allRowsCorrect = true;

    for (int r = 0; r < 5; r++) {
      bool rowOK = true;
      for (int c = 0; c < 4; c++) {
        if (userInputs[r][c] != correctAnswers[r][c]) {
          rowOK = false;
          allRowsCorrect = false;
          break;
        }
      }
      rowCorrect[r] = rowOK;
    }

    setState(() {});

    if (allRowsCorrect) {
      hasWon = true;
      await showResultDialog(true);
      setState(() {});
    } else {
      await showResultDialog(false);
      restartMateri4Screen();
    }
  }

  void restartMateri4Screen() {
    setState(() {
      cursorIndex = 0;
      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 4; c++) {
          userInputs[r][c] = '';
        }
        rowCorrect[r] = false;
      }
      lastCheckedStatus = null;
      hasWon = false;
      showWin = false;
      winAnimasi = null;
      selectedRow = 0;
    });
  }

  void handleInput(String key) {
  setState(() {

    if (key == '←') {
      return;
    }

    if (cursorIndex >= hintOrder.length) return;

    String expectedKey = hintOrder[cursorIndex];

    // hanya boleh pencet huruf yang ditunjuk cursor
    if (key != expectedKey) {
      return;
    }

    for (int i = 0; i < 4; i++) {
      if (userInputs[selectedRow][i].isEmpty) {

        userInputs[selectedRow][i] = key;

        cursorIndex++;

        bool rowFull =
            userInputs[selectedRow].every((e) => e.isNotEmpty);

        if (rowFull) {
          if (selectedRow < 4) {
            selectedRow++;
          }
        }

        break;
      }
    }

    lastCheckedStatus = null;
  });

    bool lastRowFull = userInputs[4].every((e) => e.isNotEmpty);
    if (lastRowFull) {
      autoCheckAnswers();
      return;
    }

    bool allFilled = true;
    for (int r = 0; r < 5; r++) {
      if (userInputs[r].any((e) => e.isEmpty)) {
        allFilled = false;
        break;
      }
    }
    if (allFilled) {
      autoCheckAnswers();
    }
}

  Widget carImage(String assetName) {
    return SizedBox(
      width: w(35),
      height: h(35),
      child: Image.asset('assets/images/$assetName', fit: BoxFit.contain),
    );
  }

  Widget emptyBoxRow(int rowIndex) {
    Color borderColor = Colors.black;
    double borderWidth = 1.2;

    // aktif (biru) hanya jika BELUM dicek
    if (lastCheckedStatus == null && selectedRow == rowIndex) {
      borderColor = Colors.blue;
      borderWidth = 2.5;
    }

    return Container(
      width: w(35 * 4),
      height: h(35),
      decoration: BoxDecoration(
        border: Border.all(
            color: borderColor,
            width: borderWidth), // optional biar lebih smooth
      ),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white, // selalu putih
                border: Border(
                  right: index == 3
                      ? BorderSide.none
                      : BorderSide(color: borderColor, width: borderWidth),
                ),
              ),
              child: Text(
                userInputs[rowIndex][index],
                style: TextStyle(
                  fontSize: sp(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget carRow(List<String> carAssets, int rowIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = rowIndex;
          lastCheckedStatus = null;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: carAssets
                  .map((asset) => Padding(
                        padding: EdgeInsets.only(right: w(8)),
                        child: carImage(asset),
                      ))
                  .toList(),
            ),
            emptyBoxRow(rowIndex),
          ],
        ),
      ),
    );
  }

  Widget carLabel(String assetName, String label) {
    return Column(
      children: [
        SizedBox(
          width: w(36),
          height: w(36),
          child: Image.asset('assets/images/$assetName', fit: BoxFit.contain),
        ),
        SizedBox(height: h(6)),
        Text(label, style: TextStyle(fontSize: sp(16))),
      ],
    );
  }

  void _nextMateri4Screen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi4Screen 2 berhasil terbuka!')),
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
                      carLabel('apple.png', 'A'),
                      carLabel('orange.png', 'L'),
                      carLabel('grape.png', 'E'),
                      carLabel('mango.png', 'R'),
                      carLabel('banana.png', 'U'),
                      carLabel('watermelon.png', 'B'),
                    ],
                  ),
                ),
                SizedBox(height: h(18)),
                Padding(
                  padding: EdgeInsets.all(w(18)),
                  child: Text(
                    'Temukan Kata Rahasia',
                    style: TextStyle(
                      fontSize: sp(18),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      carRow([
                        'watermelon.png',
                        'apple.png',
                        'mango.png',
                        'banana.png'
                      ], 0),
                      carRow(
                          ['orange.png', 'apple.png', 'mango.png', 'apple.png'],
                          1),
                      carRow(
                          ['mango.png', 'grape.png', 'orange.png', 'apple.png'],
                          2),
                      carRow([
                        'watermelon.png',
                        'grape.png',
                        'orange.png',
                        'apple.png'
                      ], 3),
                      carRow([
                        'apple.png',
                        'watermelon.png',
                        'orange.png',
                        'banana.png'
                      ], 4),
                    ],
                  ),
                ),
                LetterKeyboard(
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
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(4);

                    _nextMateri4Screen();

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
