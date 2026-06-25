import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/sound_manager.dart';
import '../db/db_hive.dart';

class Materi32Screen extends StatefulWidget {
  const Materi32Screen({super.key});

  @override
  State<Materi32Screen> createState() => _Materi32ScreenState();
}

class _Materi32ScreenState extends State<Materi32Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  /// JAWABAN BENAR (INDEX GLOBAL)
  final List<int> correctItems = [2, 4, 9];

  /// URUTAN PETUNJUK
final List<int> hintOrder = [2, 4, 9];

int cursorIndex = 0;

final Map<int, GlobalKey> itemKeys = {
  1: GlobalKey(),
  2: GlobalKey(),
  3: GlobalKey(),
  4: GlobalKey(),
  5: GlobalKey(),
  6: GlobalKey(),
  7: GlobalKey(),
  8: GlobalKey(),
  9: GlobalKey(),
};

  /// ITEM YANG DIPILIH
  List<int> selectedItems = [];

  /// STATUS ITEM
  Map<int, String?> itemStatus = {
    1: null,
    2: null,
    3: null,
    4: null,
    5: null,
    6: null,
    7: null,
    8: null,
    9: null,
  };

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;
  late AnimationController _controller;
late Animation<double> _bounceAnim;

  bool get allSelected => selectedItems.length == 3;

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



void restartMateri() {
  setState(() {
    selectedItems.clear();
    itemStatus.updateAll((key, value) => null);

    cursorIndex = 0;

    hasWon = false;
  });
}
  void autoCheckAnswer() async {
    if (!allSelected || hasWon) return;

    bool allCorrect = true;

    for (int i = 1; i <= 9; i++) {
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

      restartMateri();
    }
  }
  
  Offset getItemPosition(int index) {
  final context = itemKeys[index]?.currentContext;

  if (context == null) return Offset.zero;

  final box = context.findRenderObject() as RenderBox;

  final position = box.localToGlobal(Offset.zero);

  return Offset(
    position.dx + box.size.width / 2 - w(15),
    position.dy - h(25),
  );
}

Widget buildCursor() {
  if (cursorIndex >= hintOrder.length) {
    return const SizedBox();
  }

  final targetIndex =
      hintOrder[cursorIndex];

  final pos =
      getItemPosition(targetIndex);

  if (pos == Offset.zero) {
    return const SizedBox();
  }

  return Positioned(
    top: pos.dy + h(35),
    left: pos.dx,
    child: AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            _bounceAnim.value,
          ),
          child: Image.asset(
            "assets/images/cursor.png",
            width: w(40),
          ),
        );
      },
    ),
  );
}

  /// WIDGET ITEM (CLICKABLE)
  Widget itemImage(int index, String imagePath, int row) {
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

  if (cursorIndex >= hintOrder.length) {
    return;
  }

  final expectedIndex =
      hintOrder[cursorIndex];

  if (index != expectedIndex) {
    return;
  }

  setState(() {

    /// HANYA 1 PILIHAN PER ROW
    selectedItems.removeWhere((item) {
      if (row == 1) {
        return item >= 1 && item <= 3;
      }

      if (row == 2) {
        return item >= 4 && item <= 6;
      }

      if (row == 3) {
        return item >= 7 && item <= 9;
      }

      return false;
    });

    selectedItems.add(index);

    itemStatus[index] = null;

    cursorIndex++;
  });

  Future.delayed(
    const Duration(milliseconds: 300),
    autoCheckAnswer,
  );
},
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            key: itemKeys[index],
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

          /// ARROW
          if (isSelected)
            Image.asset(
              "assets/images/arrow.png",
              width: w(90),
              height: h(90),
            ),
        ],
      ),
    );
  }

  Widget rowItems(List<Widget> children) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(20), vertical: h(12)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h(20)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(w(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ),
      ),
    );
  }

  void _nextMateri() async {
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

                SizedBox(height: h(40)),

                Text(
                  "Lingkari gambar yang berbeda",
                  style: TextStyle(fontSize: sp(18)),
                ),

                SizedBox(height: h(30)),

                /// ROW 1
                rowItems([
                  itemImage(1, "assets/images/seledri.png", 1),
                  itemImage(2, "assets/images/broccoli.png", 1),
                  itemImage(3, "assets/images/seledri.png", 1),

                ]),

                /// ROW 2
                rowItems([
                  itemImage(4, "assets/images/apple.png", 2),
                  itemImage(5, "assets/images/strawberry.png", 2),
                  itemImage(6, "assets/images/strawberry.png", 2),
                ]),

                /// ROW 3
                rowItems([
                  itemImage(7, "assets/images/semut.png", 3),
                  itemImage(8, "assets/images/semut.png", 3),
                  itemImage(9, "assets/images/siput.png", 3),

                ]),
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
      floatingActionButton: hasWon
          ? Padding(
              padding: EdgeInsets.only(bottom: h(16), right: w(16)),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHive.completeMateri(32);

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
