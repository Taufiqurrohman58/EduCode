import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_letter.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi12Screen extends StatefulWidget {
  const Materi12Screen({super.key});

  @override
  State<Materi12Screen> createState() => _Materi12ScreenState();
}

class _Materi12ScreenState extends State<Materi12Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  /// MATRIX 5x5
  final List<List<String>> gridData = const [
    [
      "assets/images/12/kancil.jpg",
      "assets/images/12/ikan.jpg",
      "assets/images/12/ubur_ubur.jpg",
      "assets/images/12/koala.jpg",
      "assets/images/12/tupai.jpg",
    ],
    [
      "assets/images/12/zebra.jpg",
      "assets/images/12/harimau.jpg",
      "assets/images/12/badak.jpg",
      "assets/images/12/monyet.jpg",
      "assets/images/12/burung.jpg",
    ],
    [
      "assets/images/12/kuda_nil.jpg",
      "assets/images/12/ayam.jpg",
      "START",
      "assets/images/12/ular.jpg",
      "assets/images/12/jerapah.jpg",
    ],
    [
      "assets/images/12/kambing.jpg",
      "assets/images/12/unta.jpg",
      "assets/images/12/kuda.jpg",
      "assets/images/12/anjing.jpg",
      "assets/images/12/domba.jpg",
    ],
    [
      "assets/images/12/buaya.jpg",
      "assets/images/12/kucing.jpg",
      "assets/images/12/gajah.jpg",
      "assets/images/12/sapi.jpg",
      "assets/images/12/singa.jpg",
    ],
  ];

  /// CONTROLLER
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  /// PANJANG KATA
final Map<int, int> answerLength = {
  0: 5,
  1: 5,
  2: 6,
  3: 4,
  4: 5, // AYAM
  5: 7, // KOALA
};

  /// JAWABAN BENAR
final Map<int, String> correctAnswers = {
  0: "BADAK",
  1: "KOALA",
  2: "KUCING",
  3: "AYAM",
  4: "DOMBA",
  5: "KAMBING",
};

  int activeCard = 0;

  String? lastCheckedStatus;
  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;

  final List<String> hintOrder = [
  'B','A','D','A','K',
  'K','O','A','L','A',
  'K','U','C','I','N','G',
  'A','Y','A','M',
  'D','O','M','B','A',
  'K','A','M','B','I','N','G',
];

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

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    _controller.dispose();
    super.dispose();
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

  /// CEK SEMUA TERISI
  bool get allFilled {
    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.length != answerLength[i]) {
        return false;
      }
    }
    return true;
  }

  /// PILIH CARD
  void selectCard(int index) {
    setState(() {
      activeCard = index;
    });
  }

  /// KEYBOARD
void handleKeyTap(String key) {
  setState(() {

    if (key == '←') {
      return;
    }

    if (cursorIndex >= hintOrder.length) return;

    String expectedKey = hintOrder[cursorIndex];

    // hanya boleh huruf yang ditunjuk cursor
    if (key != expectedKey) {
      return;
    }

    var controller = controllers[activeCard];
    int maxLength = answerLength[activeCard]!;

    if (controller.text.length < maxLength) {
      controller.text += key;

      cursorIndex++;
    }

    if (controller.text.length == maxLength &&
        activeCard < controllers.length - 1) {
      activeCard++;
    }
  });

  Future.delayed(
    const Duration(milliseconds: 200),
    autoCheckAnswers,
  );
}
  void autoCheckAnswers() async {
    if (!allFilled || hasWon) return;

    bool allCorrect = true;

    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.toUpperCase() != correctAnswers[i]) {
        allCorrect = false;
        break;
      }
    }

    // 🔥 TARUH DI SINI
    setState(() {
      lastCheckedStatus = allCorrect ? "correct" : "wrong";

      // ⛔ hilangkan semua fokus (tidak ada border biru lagi)
      activeCard = -1;
    });

    if (allCorrect) {
      hasWon = true;
      await showResultDialog(true);
    } else {
      await showResultDialog(false);
      restartMateri();
    }
  }

  /// ANIMASI
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
      const SnackBar(content: Text("Materi 13 terbuka!")),
    );

    Navigator.pop(context);
  }

    /// CARD
  Widget buildArrowCard({
    required int index,
    required List<String> arrows,
  }) {
    bool isActive = activeCard == index;

    Color borderColor = Colors.black;
    double borderWidth = 1;

    if (lastCheckedStatus == null && isActive) {
      borderColor = Colors.blue;
      borderWidth = 2;
    }

    return InkWell(
      onTap: () => selectCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: w(8), vertical: h(6)),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(w(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// PANAH
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: arrows.map((img) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(2)),
                  child: Image.asset(img, width: w(20)),
                );
              }).toList(),
            ),

            SizedBox(height: h(4)),

            /// 🔥 SLOT JAWABAN (GANTI PLACEHOLDER)
            buildAnswerRow(index),
          ],
        ),
      ),
    );
  }

  Widget buildAnswerRow(int index) {
    int maxLength = answerLength[index]!;
    String text = controllers[index].text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (i) {
        String char = i < text.length ? text[i] : "";

        return Container(
          width: w(9),
          height: h(18),
          margin: EdgeInsets.symmetric(horizontal: w(1.2)),
          alignment: Alignment.center, // ⬅️ ini kunci utama
          child: Column(
            mainAxisSize: MainAxisSize.min, // ⬅️ biar tidak full tinggi
            children: [
              Text(
                char,
                style: TextStyle(
                  fontSize: sp(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2), // jarak dikit biar enak
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black,
              ),
            ],
          ),
        );
      }),
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

                SizedBox(height: h(10)),
                Padding(
                  padding: EdgeInsets.all(w(10)),
                  child: Text(
                    'Tulis nama hewan sesuai anak panah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: h(10)),

                /// GRID
                Center(
                  child: Container(
                    width: w(300),
                    height: h(300),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: List.generate(5, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(5, (col) {
                              String value = gridData[row][col];

                              return Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                          color: col != 4
                                              ? Colors.black
                                              : Colors.transparent),
                                      bottom: BorderSide(
                                          color: row != 4
                                              ? Colors.black
                                              : Colors.transparent),
                                    ),
                                  ),
                                  child: value == "START"
                                      ? Container(
                                          color: Colors.red,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "START",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.all(w(10)), 
                                          child: Image.asset(
                                            value,
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
                ),

                SizedBox(height: h(15)),

                /// CARD
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(20)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildArrowCard(
                              index: 0,
                              arrows: [
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_atas.png",
                                "assets/images/panah_kiri.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                                                            index: 1,
                                                            arrows: [
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_atas.png",
                                "assets/images/panah_atas.png",
                              ],



                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                              index: 2,
                                                            arrows: [
                                "assets/images/panah_bawah.png",
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_bawah.png",
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h(10)),
                      Row(
                        children: [
                          Expanded(
                            child: buildArrowCard(
                              index: 3,
                                                            arrows: [
                                "assets/images/panah_atas.png",
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_bawah.png",
                              ],

                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                              index: 4,
                                                            arrows: [
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_kanan.png",
                                "assets/images/panah_bawah.png",
                              ],
                            ),
                          ),
                          SizedBox(width: w(10)),
                          Expanded(
                            child: buildArrowCard(
                              index: 5,
                                                            arrows: [
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_kiri.png",
                                "assets/images/panah_bawah.png",
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
)
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
                    await DBHive.completeMateri(12);

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
