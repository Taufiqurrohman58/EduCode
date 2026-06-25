import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level37Screen extends StatefulWidget {
  const Level37Screen({super.key});

  @override
  State<Level37Screen> createState() => _Level37ScreenState();
}

class _Level37ScreenState extends State<Level37Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  final Map<String, String> correctCategory = {
    'orange.png': 'buah',
    'pear.png': 'buah',
    'apple.png': 'buah',
    'broccoli.png': 'sayur',
    'spinach.png': 'sayur',
    'cauliflower.png': 'sayur',
  };

  List<String> buahDrop = [];
  List<String> sayurDrop = [];

  List<String> availableItem = [
    'orange.png',
    'broccoli.png',
    'pear.png',
    'spinach.png',
    'apple.png',
    'cauliflower.png',
  ];

  late AnimationController _controller;

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;
  String? lastCheckedStatus;

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

  bool get allDropped => buahDrop.length == 3 && sayurDrop.length == 3;

  void restartLevel() {
    setState(() {
      buahDrop.clear();
      sayurDrop.clear();
      availableItem = [
        'orange.png',
        'broccoli.png',
        'pear.png',
        'spinach.png',
        'apple.png',
        'cauliflower.png',
      ];
      hasWon = false;
      lastCheckedStatus = null;
    });
  }

  void autoCheckAnswers() async {
    if (!allDropped || hasWon) return;

    bool allCorrect = true;

    for (var item in buahDrop) {
      if (correctCategory[item] != 'buah') {
        allCorrect = false;
        break;
      }
    }

    for (var item in sayurDrop) {
      if (correctCategory[item] != 'sayur') {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() {
        hasWon = true;
        lastCheckedStatus = 'correct';
      });
      await showResultDialog(true);
    } else {
      setState(() {
        lastCheckedStatus = 'wrong';
      });
      await showResultDialog(false);
      restartLevel();
    }
  }

  Future<void> showResultDialog(bool isCorrect) async {
    if (isCorrect) {
      setState(() {
        showWin = true;
        winAnimasi = 'assets/lottie/benar.json';
      });

      await AudioManager().playEffect('sounds/benar.mp3');
      await Future.delayed(const Duration(seconds: 3));

      setState(() => showWin = false);
    } else {
      await AudioManager().playEffect('sounds/salah.mp3');
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 38 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  /// =========================
  /// DRAG AWAL
  /// =========================
  Widget draggableItem(String asset) {
    return Draggable<String>(
      data: asset,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset('assets/images/$asset', width: w(70), height: h(70)),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset('assets/images/$asset', width: w(60), height: h(60)),
      ),
      child: Container(
        width: w(90),
        height: h(90),
        margin: EdgeInsets.all(w(4)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(w(8)),
        ),
        child: Center(
          child:
              Image.asset('assets/images/$asset', width: w(60), height: h(60)),
        ),
      ),
    );
  }

  /// =========================
  /// ITEM DI DALAM BOX (ADA BORDER)
  /// =========================
  Widget buildItemBox(String item, String category, List<String> targetList) {
    bool isCorrect = correctCategory[item] == category;

    Color borderColor = Colors.transparent;

    if (lastCheckedStatus == 'correct') {
      // semua benar → semua hijau
      borderColor = Colors.green;
    } else if (lastCheckedStatus == 'wrong') {
      // jika salah → yang benar hijau, yang salah merah
      borderColor = isCorrect ? Colors.green : Colors.red;
    }

    return Draggable<String>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset('assets/images/$item', width: w(60), height: h(60)),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset('assets/images/$item', width: w(60), height: h(60)),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            targetList.remove(item);
            availableItem.add(item);
            hasWon = false;
            lastCheckedStatus = null;
          });
        },
        child: Container(
          padding: EdgeInsets.all(w(6)),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(w(8)),
          ),
          child:
              Image.asset('assets/images/$item', width: w(60), height: h(60)),
        ),
      ),
    );
  }

  /// =========================
  /// CONTENT CELL
  /// =========================
  Widget contentCell(List<String> targetList, String category,
      {bool showRightBorder = false}) {
    return Expanded(
      child: DragTarget<String>(
        onWillAccept: (data) {
          if (targetList.length >= 3) return false;
          return true;
        },
        onAcceptWithDetails: (details) {
          final item = details.data;

          setState(() {
            buahDrop.remove(item);
            sayurDrop.remove(item);

            targetList.add(item);
            availableItem.remove(item);
          });

          Future.delayed(const Duration(milliseconds: 300), autoCheckAnswers);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            height: h(275),
            padding: EdgeInsets.all(w(10)),
            decoration: BoxDecoration(
              border: Border(
                right: showRightBorder
                    ? const BorderSide(color: Colors.black, width: 2)
                    : BorderSide.none,
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: targetList
                  .map((item) => buildItemBox(item, category, targetList))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Widget headerCell(String text, {bool showRightBorder = false}) {
    return Expanded(
      child: Container(
        height: h(50),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: showRightBorder
                ? const BorderSide(color: Colors.black, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildTable() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: w(20)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: Row(
              children: [
                headerCell("BUAH", showRightBorder: true),
                headerCell("SAYUR"),
              ],
            ),
          ),
          Row(
            children: [
              contentCell(buahDrop, 'buah', showRightBorder: true),
              contentCell(sayurDrop, 'sayur'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildItemList() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: availableItem.map((e) => draggableItem(e)).toList(),
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
                SizedBox(height: h(30)),
                buildTable(),
                SizedBox(height: h(20)),
                const Text("Pisahkan buah dan sayur!"),
                SizedBox(height: h(10)),
                buildItemList(),
              ],
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
                    await DBHive.unlockNextLevel(37);

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
