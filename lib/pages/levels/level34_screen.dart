import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Level34Screen extends StatefulWidget {
  const Level34Screen({super.key});

  @override
  State<Level34Screen> createState() => _Level34ScreenState();
}

class _Level34ScreenState extends State<Level34Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// INDEX YANG BENAR (SEMUA KECUALI 5)
  final List<int> correctItems = [5];

  /// ITEM YANG DIPILIH USER
  List<int> selectedItems = [];

  /// STATUS ITEM (correct / wrong)
  Map<int, String?> itemStatus = {
    1: null,
    2: null,
    3: null,
    4: null,
    5: null,
    6: null,
  };

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  bool get allSelected => selectedItems.length == 1;

  void restartLevel() {
    setState(() {
      selectedItems.clear();
      itemStatus.updateAll((key, value) => null);
      hasWon = false;
    });
  }

  void autoCheckAnswer() async {
    if (!allSelected || hasWon) return;

    bool allCorrect = true;

    for (int i = 1; i <= 2; i++) {
      bool isSelected = selectedItems.contains(i);
      bool shouldSelect = correctItems.contains(i);

      if (isSelected == shouldSelect) {
        itemStatus[i] = 'correct';
      } else {
        itemStatus[i] = 'wrong';
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

      restartLevel();
    }
  }

  /// ITEM GAMBAR (CLICKABLE)
  Widget itemImage(int index, String imagePath) {
    bool isSelected = selectedItems.contains(index);
    bool isCorrectItem = correctItems.contains(index);

    Color borderColor = Colors.transparent;

    if (isSelected && itemStatus[index] == 'correct') {
      borderColor = Colors.green;
    }

    if (isSelected && itemStatus[index] == 'wrong') {
      borderColor = isCorrectItem ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedItems.contains(index)) {
            selectedItems.remove(index);
          } else {
            if (selectedItems.length < 5) {
              selectedItems.add(index);
            }
          }

          itemStatus[index] = null;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          autoCheckAnswer,
        );
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: w(90),
                height: h(90),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 3),
                  borderRadius: BorderRadius.circular(w(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(w(5)),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              /// ARROW TENGAH (SAMA SEPERTI LEVEL 30)
              if (isSelected)
                Image.asset(
                  "assets/images/arrow.png",
                  width: w(90),
                  height: h(90),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget rowItems(List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(top: h(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          children[0],
          SizedBox(width: w(10)),
          children[1],
          SizedBox(width: w(10)),
          children[2],
        ],
      ),
    );
  }

  void _nextLevel() async {
    await DBHive.unlockNextLevel(34);
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
                      color: const Color(0xFFAC4616),
                      alignment: Alignment.center,
                      child: Text(
                        'DEBUGGING',
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
                  "Lingkari gambar yang tidak ada pada burger",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(20)),

                /// BURGER
                Image.asset(
                  "assets/images/34/burger.png",
                  width: w(280),
                  height: h(280),
                  fit: BoxFit.contain,
                ),

                SizedBox(height: h(10)),

                /// GRID
                Expanded(
                  child: Column(
                    children: [
                      rowItems([
                        itemImage(1, "assets/images/34/potongan1.png"),
                        itemImage(2, "assets/images/34/potongan2.png"),
                        itemImage(3, "assets/images/34/potongan3.png"),
                      ]),
                      rowItems([
                        itemImage(4, "assets/images/34/potongan4.png"),
                        itemImage(5, "assets/images/34/potongan5.png"),
                        itemImage(6, "assets/images/34/potongan6.png"),
                      ]),
                    ],
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
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.unlockNextLevel(34);

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
