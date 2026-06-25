import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Materi29Screen extends StatefulWidget {
  const Materi29Screen({super.key});

  @override
  State<Materi29Screen> createState() => _Materi29ScreenState();
}

class _Materi29ScreenState extends State<Materi29Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// MAPPING JAWABAN BENAR
  final Map<int, String> correctMapping = {
    1: "Garuk", // Gatal
    2: "Makan", // Lapar
    3: "Ke dokter", // Sakit
    4: "Minum", // Haus
    5: "Mandi", // Kotor
    6: "Tidur", // Ngantuk
    7: "Belajar", // Tidak tahu
    8: "Istirahat", // Capek
  };

  /// URUTAN PENYELESAIAN
  final List<Map<String, dynamic>> hintOrder = [
    {'id': 1, 'answer': 'Garuk'},
    {'id': 2, 'answer': 'Makan'},
    {'id': 3, 'answer': 'Ke dokter'},
    {'id': 4, 'answer': 'Minum'},
    {'id': 5, 'answer': 'Mandi'},
    {'id': 6, 'answer': 'Tidur'},
    {'id': 7, 'answer': 'Belajar'},
    {'id': 8, 'answer': 'Istirahat'},
  ];

  int cursorIndex = 0;

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

  final Map<String, GlobalKey> optionKeys = {};

  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  String? lastCheckedStatus;
  bool hasWon = false;

  bool showWin = false;
  String? winAnimasi;

@override
void initState() {
  super.initState();

  for (var item in hintOrder) {
    optionKeys["${item['id']}_${item['answer']}"] = GlobalKey();
  }

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
    if (mounted) {
      setState(() {});
    }
  });
}
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get allAnswered => !selectedAnswer.values.contains(null);

  /// RESTART LEVEL
  void restartMateri29Screen() {
    setState(() {
      selectedAnswer.updateAll((key, value) => null);

      cursorIndex = 0;

      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  Offset getOptionPosition() {
    if (cursorIndex >= hintOrder.length) {
      return Offset.zero;
    }

    final current = hintOrder[cursorIndex];

    final key = optionKeys["${current['id']}_${current['answer']}"];

    final context = key?.currentContext;

    if (context == null) return Offset.zero;

    final box = context.findRenderObject() as RenderBox;

    final pos = box.localToGlobal(Offset.zero);

    return Offset(
      pos.dx + w(5),
      pos.dy - h(15),
    );
  }

  Widget buildCursor() {
    final pos = getOptionPosition();

    if (pos == Offset.zero) {
      return const SizedBox();
    }

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnim.value),
            child: Image.asset(
              "assets/images/cursor.png",
              width: w(35),
            ),
          );
        },
      ),
    );
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

      restartMateri29Screen();
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

      restartMateri29Screen();
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

    final key = optionKeys["${id}_$text"];

    return GestureDetector(
      onTap: () {
        if (cursorIndex >= hintOrder.length) return;

        final current = hintOrder[cursorIndex];

        final expectedId = current['id'];
        final expectedAnswer = current['answer'];

        if (id != expectedId || text != expectedAnswer) {
          return;
        }

        setState(() {
          selectedAnswer[id] = text;
          cursorIndex++;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          autoCheckAnswers,
        );
      },
      child: Row(
        children: [
          Container(
            key: key,
            width: w(20),
            height: h(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              color: selected ? Colors.blue : Colors.transparent,
            ),
          ),
          SizedBox(width: w(6)),
          Text(
            text,
            style: TextStyle(
              fontSize: sp(14),
            ),
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

  void nextMateri29Screen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi29Screen 30 berhasil terbuka!')),
    );

    Navigator.pop(context);
  }

  void _nextMateri29Screen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materi29Screen 2 berhasil terbuka!')),
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
                            image: "assets/images/29/gatal.png",
                            label: "Gatal",
                            option1: "Garuk",
                            option2: "Lompat",
                          ),
                          conditionItem(
                            id: 2,
                            image: "assets/images/29/lapar.png",
                            label: "Lapar",
                            option1: "Makan",
                            option2: "Berenang",
                          ),
                        ),
                        conditionRow(
                          conditionItem(
                            id: 3,
                            image: "assets/images/29/sakit.png",
                            label: "Sakit",
                            option1: "Ke bengkel",
                            option2: "Ke dokter",
                          ),
                          conditionItem(
                            id: 4,
                            image: "assets/images/29/haus.png",
                            label: "Haus",
                            option1: "Belajar",
                            option2: "Minum",
                          ),
                        ),
                        conditionRow(
                          conditionItem(
                            id: 5,
                            image: "assets/images/29/kotor.png",
                            label: "Kotor",
                            option1: "Mandi",
                            option2: "Tidur",
                          ),
                          conditionItem(
                            id: 6,
                            image: "assets/images/29/ngantuk.png",
                            label: "Ngantuk",
                            option1: "Mandi",
                            option2: "Tidur",
                          ),
                        ),
                        conditionRow(
                          conditionItem(
                            id: 7,
                            image: "assets/images/29/tidak_tahu.png",
                            label: "Tidak tahu",
                            option1: "Makan",
                            option2: "Belajar",
                          ),
                          conditionItem(
                            id: 8,
                            image: "assets/images/29/capek.png",
                            label: "Capek",
                            option1: "Makan",
                            option2: "Istirahat",
                          ),
                        ),
                      ],
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

      /// TOMBOL LANJUT
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.completeMateri(29);

                    _nextMateri29Screen();

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
