import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level23Screen extends StatefulWidget {
  const Level23Screen({super.key});

  @override
  State<Level23Screen> createState() => _Level23ScreenState();
}

class _Level23ScreenState extends State<Level23Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  //Mapping jawaban benar
  final Map<String, String> correctMapping = {
    'semut.png': '1',
    'tikus.png': '2',
    'kucing.png': '3',
    'kambing.png': '4',
    'sapi.png': '5',
    'gajah.png': '6',
  };

  //Drop state
  Map<String, String?> droppedAnimals = {
    '1': null,
    '2': null,
    '3': null,
    '4': null,
    '5': null,
    '6': null,
  };

  //Animal draggable
  List<String> availableAnimals = [
    'kambing.png',
    'kucing.png',
    'tikus.png',
    'gajah.png',
    'sapi.png',
    'semut.png',
  ];

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

  bool get allDropped => !droppedAnimals.values.contains(null);

  //restart level
  void restartLevel() {
    setState(() {
      droppedAnimals = {
        '1': null,
        '2': null,
        '3': null,
        '4': null,
        '5': null,
        '6': null,
      };

      availableAnimals = [
        'kambing.png',
        'kucing.png',
        'tikus.png',
        'gajah.png',
        'sapi.png',
        'semut.png',
      ];

      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  //Animasi dan suara
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

  //Auto check
  void autoCheckAnswers() async {
    if (!allDropped || hasWon) return;

    bool allCorrect = true;

    for (var entry in droppedAnimals.entries) {
      final animal = entry.value;

      if (animal == null || correctMapping[animal] != entry.key) {
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

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 24 berhasil terbuka!')),
    );

    Navigator.pop(context);
  }

  //BOX NUMBER
  Widget boxedNumber(String number, {bool showRightBorder = false}) {
    final isCorrect = droppedAnimals[number] != null &&
        correctMapping[droppedAnimals[number]] == number;

    return Expanded(
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          final animal = details.data;

          setState(() {
            if (droppedAnimals[number] != null) {
              if (!availableAnimals.contains(droppedAnimals[number]!)) {
                availableAnimals.add(droppedAnimals[number]!);
              }
            }

            droppedAnimals.updateAll((key, value) {
              if (value == animal) return null;
              return value;
            });

            droppedAnimals[number] = animal;

            availableAnimals.remove(animal);
          });

          Future.delayed(const Duration(milliseconds: 300), autoCheckAnswers);
        },
        builder: (context, candidateData, rejectedData) {
          final droppedAnimal = droppedAnimals[number];

          final isFilled = droppedAnimal != null;

          Color borderColor = Colors.black;

          if (lastCheckedStatus == 'correct' && isCorrect) {
            borderColor = Colors.green;
          } else if (lastCheckedStatus == 'wrong' && isFilled) {
            borderColor = Colors.red;
          }

          return Container(
            height: h(100),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: borderColor, width: 2),
                top: BorderSide(color: borderColor, width: 2),
                bottom: BorderSide(color: borderColor, width: 2),
                right: showRightBorder
                    ? BorderSide(color: borderColor, width: 2)
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: droppedAnimal == null
                  ? Text(
                      number,
                      style: TextStyle(
                          fontSize: sp(48), fontWeight: FontWeight.w600),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          final animal = droppedAnimals[number];

                          if (animal != null) {
                            if (!availableAnimals.contains(animal)) {
                              availableAnimals.add(animal);
                            }

                            droppedAnimals[number] = null;

                            lastCheckedStatus = null;
                            hasWon = false;
                          }
                        });
                      },
                      child: Image.asset(
                        'assets/images/23/$droppedAnimal',
                        width: w(60),
                        height: h(60),
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  //Draggable Animal
  Widget dashedAnimal(String assetName) {
    String label = assetName.replaceAll('.png', '');

    return Draggable<String>(
      data: assetName,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(
          'assets/images/23/$assetName',
          width: w(70),
          height: h(70),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(
          'assets/images/23/$assetName',
          width: w(60),
          height: h(60),
        ),
      ),
      child: Container(
        width: w(90),
        height: h(100),
        margin: EdgeInsets.all(w(4)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(w(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/23/$assetName',
              width: w(60),
              height: h(60),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: sp(14),
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAnimalRows() {
    final topRow = availableAnimals.take(3).toList();
    final bottomRow = availableAnimals.skip(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: topRow.map((a) => dashedAnimal(a)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: bottomRow.map((a) => dashedAnimal(a)).toList(),
        ),
      ],
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
            SingleChildScrollView(
              child: Column(
                children: [
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

                  //GRID BOX
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w(28)),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Row(
                        children: [
                          boxedNumber('1', showRightBorder: true),
                          boxedNumber('2', showRightBorder: true),
                          boxedNumber('3', showRightBorder: true),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: h(18)),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w(28)),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Row(
                        children: [
                          boxedNumber('4', showRightBorder: true),
                          boxedNumber('5', showRightBorder: true),
                          boxedNumber('6', showRightBorder: true),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: h(30)),

                  Text(
                    'Cocokkan hewan dengan angka!',
                    style: TextStyle(
                      fontSize: sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: h(20)),

                  buildAnimalRows(),

                  SizedBox(height: h(100)),
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
                    await DBHive.unlockNextLevel(23);

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
