import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_number.dart';
import '../db/db_hive.dart';

class Materi24Screen extends StatefulWidget {
  const Materi24Screen({super.key});

  @override
  State<Materi24Screen> createState() => _Materi24ScreenState();
}

class _Materi24ScreenState extends State<Materi24Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// =========================
  /// JAWABAN BENAR
  /// =========================
  final List<int> correctAnswers = [1, 2, 2, 1];

  /// INPUT USER
  List<String> userInputs = List.filled(4, '');

  /// STATUS BENAR
  List<bool> boxCorrect = List.filled(4, false);

  int activeIndex = 0;

  String? lastCheckedStatus;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  final List<String> hintOrder = ['1', '2', '2', '1'];

  int cursorIndex = 0;

  final Map<String, GlobalKey> keyMap = {
    for (var k in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'])
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

  /// =========================
  /// HANDLE KEYBOARD
  /// =========================
  void handleKeyboard(String key) {
    if (lastCheckedStatus != null) return;

    setState(() {
      if (key == '←') {
        return;
      }

      if (cursorIndex >= hintOrder.length) return;

      String expectedKey = hintOrder[cursorIndex];

      /// hanya menerima angka sesuai petunjuk
      if (key != expectedKey) {
        return;
      }

      if (userInputs[activeIndex].isEmpty) {
        userInputs[activeIndex] = key;

        cursorIndex++;

        for (int i = activeIndex + 1; i < userInputs.length; i++) {
          if (userInputs[i].isEmpty) {
            activeIndex = i;
            break;
          }
        }
      }
    });

    autoCheck();
  }

  /// =========================
  /// AUTO CHECK
  /// =========================
  void autoCheck() async {
    for (String val in userInputs) {
      if (val.isEmpty) return;
    }

    bool allCorrect = true;

    for (int i = 0; i < correctAnswers.length; i++) {
      bool ok = userInputs[i] == correctAnswers[i].toString();

      boxCorrect[i] = ok;

      if (!ok) allCorrect = false;
    }

    setState(() {
      activeIndex = -1; // tidak ada yang aktif
    });

    if (allCorrect) {
      await showResultDialog(true);

      hasWon = true;

      setState(() {});
    } else {
      await showResultDialog(false);

      /// supaya pemain lihat merah/hijau dulu
      await Future.delayed(const Duration(milliseconds: 1500));

      restart();
    }
  }

  /// =========================
  /// DIALOG RESULT
  /// =========================
  Future<void> showResultDialog(bool correct) async {
    setState(() {
      lastCheckedStatus = correct ? "correct" : "wrong";

      if (correct) {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      }
    });

    if (correct) {
      await AudioManager().playEffect('sounds/benar.mp3');

      await Future.delayed(const Duration(seconds: 2));

      setState(() => showWin = false);
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// =========================
  /// RESET
  /// =========================
  void restart() {
    setState(() {
      userInputs = List.filled(4, '');
      boxCorrect = List.filled(4, false);
      activeIndex = 0;
      cursorIndex = 0;
      lastCheckedStatus = null;
      showWin = false;
      hasWon = false;
    });
  }

  /// =========================
  /// LINGKARAN INPUT
  /// =========================
  Widget answerCircle(int index) {
    Color borderColor;

    /// SEBELUM CEK
    if (lastCheckedStatus == null) {
      borderColor = index == activeIndex ? Colors.blue : Colors.black;
    }

    /// SESUDAH CEK
    else {
      borderColor = boxCorrect[index] ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () {
        /// tidak bisa pilih setelah cek
        if (lastCheckedStatus != null) return;

        setState(() {
          activeIndex = index;
        });
      },
      child: Container(
        width: w(28),
        height: h(28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
        ),
        child: Text(
          userInputs[index],
          style: TextStyle(
            fontSize: sp(14),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// ITEM GRID
  /// =========================
  Widget gridItem(String image, int index) {
    return Stack(
      children: [
        Center(
          child: Image.asset(
            image,
            width: w(120),
            height: h(120),
          ),
        ),
        Positioned(
          top: h(12),
          left: w(12),
          child: answerCircle(index),
        ),
      ],
    );
  }

  /// =========================
  /// GRID 2x2
  /// =========================
  Widget buildGrid2x2() {
    final images = [
      "assets/images/24/b1.png",
      "assets/images/24/b2.png",
      "assets/images/24/a1.png",
      "assets/images/24/a2.png",
    ];

    return Container(
      width: w(330),
      height: h(330),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: (index % 2 != 1) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: (index < 2) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: gridItem(images[index], index),
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

  /// =========================
  /// UI
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
                /// HEADER
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h(66),
                      color: const Color(0xFFF79055),
                      alignment: Alignment.center,
                      child: Text(
                        'SEQUENCE',
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

                SizedBox(height: h(50)),

                Text(
                  textAlign: TextAlign.center,
                  "Urutkan dari yang termuda hingga tertua\nAngka 1 berarti termuda",
                  style: TextStyle(fontSize: sp(16)),
                ),

                SizedBox(height: h(40)),

                buildGrid2x2(),

                const Spacer(),

                /// KEYBOARD
                NumberKeyboard(
                  onKeyTap: handleKeyboard,
                  keyMap: keyMap,
                ),
              ],
            ),
            buildKeyboardCursor(),

            /// ANIMASI MENANG
            if (showWin)
              Center(
                child: Lottie.asset(
                  winAnimasi!,
                  width: w(250),
                  repeat: false,
                ),
              ),
          ],
        ),
      ),

      /// TOMBOL LANJUT
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.completeMateri(24);

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
