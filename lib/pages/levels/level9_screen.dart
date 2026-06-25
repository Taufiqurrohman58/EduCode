import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level9Screen extends StatefulWidget {
  const Level9Screen({super.key});

  @override
  State<Level9Screen> createState() => _Level9ScreenState();
}

class _Level9ScreenState extends State<Level9Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// JAWABAN BENAR
  final Map<int, Set<String>> correctAnswers = {
    1: {"HITAM", "PUTIH"},
    2: {"HITAM", "OREN"},
    3: {"HIJAU", "KUNING"},
    4: {"PUTIH", "BIRU"},
  };

  /// PILIHAN USER
  Map<int, Set<String>> selectedColors = {
    1: {},
    2: {},
    3: {},
    4: {},
  };

  Map<int, String?> questionStatus = {
    1: null,
    2: null,
    3: null,
    4: null,
  };

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void restartLevel9Screen() {
    setState(() {
      selectedColors = {
        1: {},
        2: {},
        3: {},
        4: {},
      };

      questionStatus = {
        1: null,
        2: null,
        3: null,
        4: null,
      };

      hasWon = false;
    });
  }

  /// CHECK SEMUA SOAL
  bool get allAnswered => selectedColors.values.every((e) => e.length == 2);

  /// AUTO CHECK
  void autoCheckAnswers() async {
    if (!allAnswered || hasWon) return;

    bool allCorrect = true;

    for (int i = 1; i <= 4; i++) {
      if (selectedColors[i]!.containsAll(correctAnswers[i]!)) {
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

      restartLevel9Screen(); // RESET SEMUA PILIHAN
    }
  }

  /// ITEM WARNA
  Widget colorItem(int questionIndex, Color color, String text) {
    bool selected = selectedColors[questionIndex]!.contains(text);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (selected) {
              selectedColors[questionIndex]!.remove(text);
            } else {
              if (selectedColors[questionIndex]!.length < 2) {
                selectedColors[questionIndex]!.add(text);
              }
            }

            questionStatus[questionIndex] = null;
          });

          Future.delayed(const Duration(milliseconds: 300), autoCheckAnswers);
        },
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: w(18),
                  height: h(18),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black, // 🔥 selalu hitam
                      width: 2,
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    left: -11,
                    top: -11,
                    child: Image.asset(
                      "assets/images/arrow.png",
                      width: w(40),
                      height: h(40),
                    ),
                  ),
              ],
            ),
            SizedBox(width: w(6)),
            Text(
              text,
              style: TextStyle(
                fontSize: sp(13),
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// GRID WARNA
  Widget colorGrid(int questionIndex) {
    return Column(
      children: [
        Row(
          children: [
            colorItem(questionIndex, const Color(0xff5AA6D1), "BIRU"),
            colorItem(questionIndex, const Color(0xff49B06B), "HIJAU"),
            colorItem(questionIndex, const Color(0xffF44336), "MERAH"),
          ],
        ),
        SizedBox(height: h(10)),
        Row(
          children: [
            colorItem(questionIndex, const Color(0xff6F63B6), "UNGU"),
            colorItem(questionIndex, Colors.black, "HITAM"),
            colorItem(questionIndex, const Color(0xffE7C84B), "KUNING"),
          ],
        ),
        SizedBox(height: h(10)),
        Row(
          children: [
            colorItem(questionIndex, const Color(0xffE06FA5), "PINK"),
            colorItem(questionIndex, Colors.white, "PUTIH"),
            colorItem(questionIndex, const Color(0xffF08C46), "OREN"),
          ],
        ),
      ],
    );
  }

  /// ITEM SOAL
  Widget questionItem(int index, String imagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(18)),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                imagePath,
                width: w(80),
                height: h(80),
              ),
              SizedBox(width: w(20)),
              Expanded(
                child: colorGrid(index),
              ),
            ],
          ),
          SizedBox(height: h(20)),
          const Divider(),
          SizedBox(height: h(20)),
        ],
      ),
    );
  }

  void _nextLevel9Screen() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level9Screen 10 berhasil terbuka!')),
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
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: h(66),
                        color: const Color(0xFFEE3E3E),
                        alignment: Alignment.center,
                        child: Text(
                          'DECOMPOSITION',
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
                                AudioManager()
                                    .playVoice('sounds/level_1&2.mp3');
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
                  Text(
                    "Pilih 2 warna yang ada dalam gambar",
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: h(25)),
                  questionItem(1, "assets/images/9/bola1.png"),
                  questionItem(2, "assets/images/9/bola2.png"),
                  questionItem(3, "assets/images/9/bola3.png"),
                  questionItem(4, "assets/images/9/bola4.png"),
                  SizedBox(height: h(120)),
                ],
              ),
            ),
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
                    await DBHive.unlockNextLevel(9);

                    _nextLevel9Screen();

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
