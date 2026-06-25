import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_letter.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi14Screen extends StatefulWidget {
  const Materi14Screen({super.key});

  @override
  State<Materi14Screen> createState() => _Materi14ScreenState();
}

class _Materi14ScreenState extends State<Materi14Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// MATRIX
  final List<List<dynamic>> gridData = const [
    ["W", "A", "G", "N", "I", "P", "M", "U"],
    ["E", "T", Colors.orange, "A", "I", "A", "R", "A"],
    ["F", "J", "L", "O", "R", Colors.pink, "A", "K"],
    ["G", "I", "D", Colors.red, "Z", "U", "H", "A"],
    ["U", "A", "B", "U", "R", "A", Colors.purple, "B"],
    ["I", Colors.green, "N", "A", "S", "T", "M", "O"],
    ["D", "U", "Y", "R", Colors.blue, "K", "A", "S"],
    ["A", "K", "I", "C", "E", "P", "I", "S"],
  ];

  /// JAWABAN BENAR
  final Map<int, String> correctAnswers = {
    0: "KAS",
    1: "BAK",
    2: "ABU",
    3: "DIA",
    4: "AIR",
    5: "API",
  };

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
  'K','A','S',
  'B','A','K',
  'A','B','U',
  'D','I','A',
  'A','I','R',
  'A','P','I',
];

  /// CONTROLLER
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  int activeCard = 0;

  /// ANIMATION
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


  /// CEK SEMUA TERISI
  bool get allFilled {
    for (var c in controllers) {
      if (c.text.length != 3) return false;
    }
    return true;
  }

  /// RESET LEVEL
  void restartMateri() {
    
    for (var c in controllers) {
      c.clear();
    }

    setState(() {
      activeCard = 0;

      cursorIndex = 0;

      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  /// PILIH CARD
  void selectCard(int index) {
    setState(() {
      activeCard = index;
    });
  }

  /// HANDLE KEYBOARD
void handleKeyTap(String key) {
  setState(() {

    if (key == '←') {
      return;
    }

    if (cursorIndex >= hintOrder.length) return;

    String expectedKey = hintOrder[cursorIndex];

    if (key != expectedKey) {
      return;
    }

    var controller = controllers[activeCard];
    String text = controller.text;

    if (text.length < 3) {
      controller.text += key;

      cursorIndex++;
    }

    if (controller.text.length == 3 &&
        activeCard < controllers.length - 1) {
      activeCard++;
    }
  });

  Future.delayed(
    const Duration(milliseconds: 200),
    autoCheckAnswers,
  );
}

  /// AUTO CHECK
  void autoCheckAnswers() async {
    if (!allFilled || hasWon) return;

    bool allCorrect = true;

    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.toUpperCase() != correctAnswers[i]) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() {
        lastCheckedStatus = "correct";
        hasWon = true;

        activeCard = -1; // 🔥 NONAKTIFKAN SEMUA
      });

      _controller.forward(from: 0);

      await showResultDialog(true);
    } else {
        setState(() {
          lastCheckedStatus = "wrong";

          activeCard = -1; // 🔥 NONAKTIFKAN SEMUA
        });

      _controller.forward(from: 0);

      await showResultDialog(false);

      restartMateri();
    }
  }

  /// ANIMASI HASIL
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
    }
  }

  /// NEXT LEVEL
  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Materi 15 terbuka!")),
    );

    Navigator.pop(context);
  }

  /// CARD
  Widget buildStartCard({
    required int index,
    required String title,
    required Color color,
    required List<String> images,
  }) {
    bool isActive = activeCard == index;

    Color borderColor = Colors.black;
    bool isCheckingDone = lastCheckedStatus != null;

    return InkWell(
      onTap: () {
        selectCard(index);
      },
      child: Container(
        padding: EdgeInsets.all(w(3)),
        decoration: BoxDecoration(
          color: color,


          border: Border.all(
            color: (!isCheckingDone && isActive)
                ? Colors.blue
                : borderColor,
            width: (!isCheckingDone && isActive) ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(w(10)),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: sp(10),
              ),
            ),
            SizedBox(height: h(3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((img) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(3)),
                  child: Image.asset(
                    img,
                    width: w(15),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: h(3)),
            Container(
              width: w(50),
              height: h(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(w(5)),
              ),
              child: TextField(
                controller: controllers[index],
                readOnly: true,
                textAlign: TextAlign.center,
                maxLength: 3,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sp(10),
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            )
          ],
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
                      color: const Color(0xFF62B4E4),
                      alignment: Alignment.center,
                      child: Text(
                        'ALGORITHM',
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

                Padding(
                  padding: EdgeInsets.all(w(10)),
                  child: Text(
                    'Temukan kata tersembunyi \n dengan mengikuti panah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                /// GRID
                Center(
                  child: Container(
                    width: w(290),
                    height: h(290),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: List.generate(8, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(8, (col) {
                              var cell = gridData[row][col];

                              return Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: cell is Color ? cell : Colors.white,
                                    border: Border(
                                      right: BorderSide(
                                          color: col != 7
                                              ? Colors.black
                                              : Colors.transparent),
                                      bottom: BorderSide(
                                          color: row != 7
                                              ? Colors.black
                                              : Colors.transparent),
                                    ),
                                  ),
                                  child: cell is String
                                      ? Text(
                                          cell,
                                          style: TextStyle(
                                            fontSize: sp(18),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// CARD
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(20)),
                  child: Column(
                    children: [
 Row(
  children: [
    Expanded(
      child: buildStartCard(
        index: 0,
        title: "START BIRU",
        color: Colors.blue,
        images: [
          "assets/images/panah_kanan_b.png",
          "assets/images/panah_kanan_b.png",
          "assets/images/panah_kanan_b.png",
        ],
      ),
    ),
    SizedBox(width: w(10)),
    Expanded(
      child: buildStartCard(
        index: 1,
        title: "START UNGU",
        color: Colors.purple,
        images: [
          "assets/images/panah_kanan_u.png",
          "assets/images/panah_atas_u.png",
          "assets/images/panah_atas_u.png",
        ],
      ),
    ),
    SizedBox(width: w(10)),
    Expanded(
      child: buildStartCard(
        index: 2,
        title: "START HIJAU",
        color: Colors.green,
        images: [
          "assets/images/panah_atas_h.png",
          "assets/images/panah_kanan_h.png",
          "assets/images/panah_kanan_h.png",
        ],
      ),
    ),
  ],
),

SizedBox(height: h(10)),

Row(
  children: [
    Expanded(
      child: buildStartCard(
        index: 3, // START MERAH pindah ke sini
        title: "START MERAH",
        color: Colors.red,
        images: [
          "assets/images/panah_kiri_m.png",
          "assets/images/panah_kiri_m.png",
          "assets/images/panah_bawah_m.png",
        ],
      ),
    ),
    SizedBox(width: w(10)),
    Expanded(
      child: buildStartCard(
        index: 4,
        title: "START OREN",
        color: Colors.orange,
        images: [
          "assets/images/panah_kanan_o.png",
          "assets/images/panah_kanan_o.png",
          "assets/images/panah_bawah_o.png",
        ],
      ),
    ),
    SizedBox(width: w(10)),
    Expanded(
      child: buildStartCard(
        index: 5,
        title: "START PINK",
        color: Colors.pink,
        images: [
          "assets/images/panah_atas_p.png",
          "assets/images/panah_atas_p.png",
          "assets/images/panah_kiri_p.png",
        ],
      ),
    ),
  ],
),
                    ],
                  ),
                ),

                const Spacer(),

LetterKeyboard(
  onKeyTap: handleKeyTap,
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
                    await DBHive.completeMateri(14);

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
