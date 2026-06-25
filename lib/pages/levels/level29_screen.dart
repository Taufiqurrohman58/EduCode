import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level29Screen extends StatefulWidget {
  const Level29Screen({super.key});

  @override
  State<Level29Screen> createState() => _Level29ScreenState();
}

class _Level29ScreenState extends State<Level29Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// MAPPING JAWABAN BENAR
  final Map<int, String> correctMapping = {
    1: "Makan",
    2: "Minum",
    3: "Tidur",
    4: "Istirahat",
    5: "Belajar",
    6: "Mandi",
    7: "Ke dokter",
    8: "Garuk",
  };

  /// JAWABAN USER
  Map<int, String?> selectedAnswer = {
    1: null,
    2: null,
    3: null,
    4: null,
    5: null,
    6: null,
    7: null,
    8: null,
  };

  late AnimationController _controller;

  String? lastCheckedStatus;
  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

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

  bool get allAnswered => !selectedAnswer.values.contains(null);

  /// RESTART LEVEL
  void restartLevel() {
    setState(() {
      selectedAnswer.updateAll((key, value) => null);
      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  /// ANIMASI & SOUND
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

      restartLevel();
    }
  }

  /// AUTO CHECK JAWABAN
  void autoCheckAnswers() async {
    if (!allAnswered || hasWon) return;

    bool allCorrect = true;

    for (var entry in selectedAnswer.entries) {
      if (correctMapping[entry.key] != entry.value) {
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

      restartLevel();
    }
  }

  void selectOption(int id, String value) {
    setState(() {
      selectedAnswer[id] = value;
    });

    Future.delayed(const Duration(milliseconds: 300), autoCheckAnswers);
  }

  /// OPTION RADIO
  Widget option(int id, String text) {
    final selected = selectedAnswer[id] == text;

    final isCorrect = selected && correctMapping[id] == text;

    Color borderColor = Colors.black;

    if (lastCheckedStatus == 'correct' && isCorrect) {
      borderColor = Colors.green;
    } else if (lastCheckedStatus == 'wrong' && selected) {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: () => selectOption(id, text),
      child: Row(
        children: [
          Container(
            width: w(20),
            height: h(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
              color: selected ? Colors.blue : Colors.transparent,
            ),
          ),
          SizedBox(width: w(6)),
          Text(
            text,
            style: TextStyle(fontSize: sp(14)),
          ),
        ],
      ),
    );
  }

  /// ITEM KONDISI
  Widget conditionItem({
    required int id,
    required String image,
    required String label,
    required String option1,
    required String option2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// GAMBAR
        SizedBox(
          width: w(70),
          child: Column(
            children: [
              Image.asset(
                image,
                width: w(60),
                height: h(60),
              ),
              SizedBox(height: h(4)),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: sp(14),
                ),
              ),
            ],
          ),
        ),

        /// OPTION
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h(15)),
              option(id, option1),
              SizedBox(height: h(8)),
              option(id, option2),
            ],
          ),
        ),
      ],
    );
  }

  /// ROW
  Widget conditionRow(Widget left, Widget right) {
    return Padding(
      padding: EdgeInsets.only(bottom: h(40)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          SizedBox(width: w(1)),
          Expanded(child: right),
        ],
      ),
    );
  }

  void nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 30 berhasil terbuka!')),
    );

    Navigator.pop(context);
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
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
                  "Pilih jawaban yang tepat",
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(20)),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: h(10)),
                    child: Column(
                      children: [
                        conditionRow(
                          conditionItem(
                            id: 1,
                            image: "assets/images/29/lapar.png",
                            label: "Lapar",
                            option1: "Makan",
                            option2: "Berenang",
                          ),
                          conditionItem(
                            id: 2,
                            image: "assets/images/29/haus.png",
                            label: "Haus",
                            option1: "Belajar",
                            option2: "Minum",
                          ),
                        ),
                        conditionRow(
                          conditionItem(
                            id: 3,
                            image: "assets/images/29/ngantuk.png",
                            label: "Ngantuk",
                            option1: "Mandi",
                            option2: "Tidur",
                          ),
                          conditionItem(
                            id: 4,
                            image: "assets/images/29/capek.png",
                            label: "Capek",
                            option1: "Makan",
                            option2: "Istirahat",
                          ),
                        ),
                        conditionRow(
                          conditionItem(
                            id: 5,
                            image: "assets/images/29/tidak_tahu.png",
                            label: "Tidak tahu",
                            option1: "Makan",
                            option2: "Belajar",
                          ),
                          conditionItem(
                            id: 6,
                            image: "assets/images/29/kotor.png",
                            label: "Kotor",
                            option1: "Mandi",
                            option2: "Tidur",
                          ),
                        ),
                        conditionRow(
                          conditionItem(
                            id: 7,
                            image: "assets/images/29/sakit.png",
                            label: "Sakit",
                            option1: "Ke bengkel",
                            option2: "Ke dokter",
                          ),
                          conditionItem(
                            id: 8,
                            image: "assets/images/29/gatal.png",
                            label: "Gatal",
                            option1: "Garuk",
                            option2: "Lompat",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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

      /// TOMBOL LANJUT
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(29);

                    _nextLevel();

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
