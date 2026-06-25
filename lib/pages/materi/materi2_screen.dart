import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../widgets/keyboard_number.dart';
import '../db/db_hive.dart';

class Materi2Screen extends StatefulWidget {
  const Materi2Screen({super.key});

  @override
  State<Materi2Screen> createState() => _Materi2ScreenState();
}

class _Materi2ScreenState extends State<Materi2Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  int cursorIndex = 0;

  final List<String> cursorOrder = [
    '1','3','6','2',
    '4','5','1','3',
    '2','2','6','5',
    '5','4','3','1',
    '6','1','2','4',
  ];
  final List<List<String>> correctAnswers = [
    ['1', '3', '6', '2'], // blue, red, purple, green
    ['4', '5', '1', '3'], // pink, orange, blue, red
    ['2', '2', '6', '5'], // green, green, purple, orange
    ['5', '4', '3', '1'], // orange, pink, red, blue
    ['6', '1', '2', '4'], // purple, blue, green, pink
  ];

  final Map<String, GlobalKey> keyMap = {
    for (var k in ['1','2','3','4','5','6','7','8','9','0'])
      k: GlobalKey(),
  };


  final List<List<String>> userInputs =
      List.generate(5, (_) => List.filled(4, ''));

  int selectedRow = 0;
  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;
  late AnimationController _controller;

  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _bounceAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    /// 🔥 TAMBAHKAN INI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
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
      position.dx + box.size.width / 2 - w(5), // center cursor
      position.dy - h(10), // sedikit di atas tombol
    );
  }
  Widget buildKeyboardCursor() {
    if (cursorIndex >= cursorOrder.length) return const SizedBox();

    String currentKey = cursorOrder[cursorIndex];
    final pos = getKeyPosition(currentKey);

    /// 🔥 kalau belum siap, jangan tampilkan dulu
    if (pos == Offset.zero) return const SizedBox();

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

  void handleInput(String key) {
    if (key == '←') return;
    /// 🔒 HANYA TERIMA INPUT SESUAI URUTAN
    if (cursorIndex >= cursorOrder.length) return;

    String expectedKey = cursorOrder[cursorIndex];

    /// ❌ kalau salah → abaikan
    if (key != expectedKey) {
      return;
    }

    setState(() {
      for (int i = 0; i < 4; i++) {
        if (userInputs[selectedRow][i].isEmpty) {
          userInputs[selectedRow][i] = key;

          /// lanjut cursor
          cursorIndex++;

          /// ✅ CEK SELESAI

          /// ✅ CEK SELESAI
          if (cursorIndex == cursorOrder.length) {
            hasWon = true;

            /// 🔊 SOUND BENAR
            AudioManager().playEffect('sounds/benar.mp3');

            /// 🎉 ANIMASI MENANG
            showWin = true;
            winAnimasi = 'assets/lottie/benar.json';

            /// ⏳ hilangkan animasi setelah 3 detik
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  showWin = false;
                });
              }
            });
          }

          /// pindah row otomatis
          bool rowFull = userInputs[selectedRow].every((e) => e.isNotEmpty);
          if (rowFull && selectedRow < 4) {
            selectedRow++;
          }

          break;
        }
      }
    });
  }

  Widget carImage(String assetName) {
    return SizedBox(
      width: w(35),
      height: h(35),
      child: Image.asset('assets/images/$assetName', fit: BoxFit.contain),
    );
  }

  Widget emptyBoxRow(int rowIndex) {
    return Container(
      width: w(35 * 4),
      height: w(35),
      decoration: BoxDecoration(
        border: Border.all(
          color: _getBorderColor(rowIndex),
          width: w(1.2),
        ),
      ),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Stack(
              children: [
                Center(
                  child: Text(
                    userInputs[rowIndex][index],
                    style: TextStyle(
                        fontSize: sp(18), fontWeight: FontWeight.bold),
                  ),
                ),

                /// GARIS PEMBATAS (biar gak double)
                if (index != 3)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: w(1.2),
                      color: _getBorderColor(rowIndex),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _getBorderColor(int rowIndex) {
    return selectedRow == rowIndex
        ? Colors.blue
        : Colors.black;
  }

  Widget carRow(List<String> carAssets, int rowIndex) {
    return GestureDetector(
      onTap: null,
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

  void _nextMateri() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // base width 360
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
                      carLabel('car_blue.png', '1'),
                      carLabel('car_green.png', '2'),
                      carLabel('car_red.png', '3'),
                      carLabel('car_pink.png', '4'),
                      carLabel('car_orange.png', '5'),
                      carLabel('car_purple.png', '6'),
                    ],
                  ),
                ),
                SizedBox(height: h(18)),
                Padding(
                  padding: EdgeInsets.all(w(20)),
                  child: Text(
                    'Kasih angka yang tepat sesuai contoh',
                    style: TextStyle(
                      fontSize: sp(16),
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
                        'car_blue.png',
                        'car_red.png',
                        'car_purple.png',
                        'car_green.png'
                      ], 0),

                      carRow([
                        'car_pink.png',
                        'car_orange.png',
                        'car_blue.png',
                        'car_red.png'
                      ], 1),

                      carRow([
                        'car_green.png',
                        'car_green.png',
                        'car_purple.png',
                        'car_orange.png'
                      ], 2),

                      carRow([
                        'car_orange.png',
                        'car_pink.png',
                        'car_red.png',
                        'car_blue.png'
                      ], 3),

                      carRow([
                        'car_purple.png',
                        'car_blue.png',
                        'car_green.png',
                        'car_pink.png'
                      ], 4),
                    ],
                  ),
                ),
                NumberKeyboard(
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
                    await DBHive.completeMateri(2);
                    // await DBHive.unlockNextMateri(1);

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
