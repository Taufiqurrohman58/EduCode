import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import 'package:lottie/lottie.dart';
import '../db/db_hive.dart';

class Level1Screen extends StatefulWidget {
  const Level1Screen({super.key});

  @override
  State<Level1Screen> createState() => _Level1ScreenState();
}

class _Level1ScreenState extends State<Level1Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive

  //mapping jawaban yang benar
  final Map<String, String> correctMapping = {
    'snake.png': '1',
    'zebra.png': '2',
    'cat.png': '3',
    'fish.png': '4',
    'monkey.png': '5',
    'koala.png': '6',
  };

  //penyimpanan drop
  Map<String, String?> droppedAnimals = {
    '1': null,
    '2': null,
    '3': null,
    '4': null,
    '5': null,
    '6': null,
  };

  //list hewan yang bisa di drag
  List<String> availableAnimals = [
    'zebra.png',
    'monkey.png',
    'koala.png',
    'cat.png',
    'fish.png',
    'snake.png',
  ];

  //Animation Controller
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
        'zebra.png',
        'monkey.png',
        'koala.png',
        'cat.png',
        'fish.png',
        'snake.png',
      ];
      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  //Animasi & Suara
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

  //Auto Check Jawaban
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
      const SnackBar(content: Text('Level 2 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  Widget animalLabel(String assetName, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: w(36),
          height: h(36),
          child: Image.asset('assets/images/$assetName', fit: BoxFit.contain),
        ),
        SizedBox(height: h(6)),
        Text(label,
            style: TextStyle(
              fontSize: sp(16),
            )),
      ],
    );
  }

  //DragTarget (Kotak Angka)
  Widget boxedNumber(String number, {bool showRightBorder = false}) {
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

          Color borderColor = Color(0xFF121212);


          return Container(
            height: h(100),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: borderColor, width: w(2)),
                top: BorderSide(color: borderColor, width: w(2)),
                bottom: BorderSide(color: borderColor, width: w(2)),
                right: showRightBorder
                    ? BorderSide(color: borderColor, width: w(2))
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
                  : Draggable<String>(
                      data: droppedAnimal,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/images/$droppedAnimal',
                          width: w(60),
                          height: h(60),
                          fit: BoxFit.contain,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          'assets/images/$droppedAnimal',
                          width: w(60),
                          height: h(60),
                          fit: BoxFit.contain,
                        ),
                      ),
                      onDraggableCanceled: (velocity, offset) {
                        setState(() {
                          droppedAnimals.updateAll((key, value) {
                            if (key == number) return droppedAnimals[number];
                            return value;
                          });
                        });
                      },
                      child: GestureDetector(
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
                          'assets/images/$droppedAnimal',
                          width: w(60),
                          height: h(60),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  //Draggable (Hewan)
  Widget dashedAnimal(String assetName) {
    return Draggable<String>(
      data: assetName,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(
          'assets/images/$assetName',
          width: w(70),
          height: h(70),
          fit: BoxFit.contain,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(
          'assets/images/$assetName',
          width: w(60),
          height: h(60),
          fit: BoxFit.contain,
        ),
      ),
      onDraggableCanceled: (velocity, offset) {},
      child: Container(
        width: 90 * scale,
        height: 90 * scale,
        margin: EdgeInsets.all(w(4)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(w(8)),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/$assetName',
            fit: BoxFit.contain,
            width: w(60),
            height: h(60),
          ),
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
                  SizedBox(height: h(18)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w(18)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        animalLabel('snake.png', '1'),
                        animalLabel('zebra.png', '2'),
                        animalLabel('cat.png', '3'),
                        animalLabel('fish.png', '4'),
                        animalLabel('monkey.png', '5'),
                        animalLabel('koala.png', '6'),
                      ],
                    ),
                  ),
                  SizedBox(height: h(18)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w(28)),
                    child: Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFF121212), width: w(2))),
                        child: Row(
                          children: [
                            boxedNumber('1', showRightBorder: true),
                            boxedNumber('4', showRightBorder: true),
                            boxedNumber('2', showRightBorder: true),
                          ],
                        )),
                  ),
                  SizedBox(height: h(28)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w(28)),
                    child: Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFF121212), width: w(2))),
                        child: Row(
                          children: [
                            boxedNumber('3', showRightBorder: true),
                            boxedNumber('6', showRightBorder: true),
                            boxedNumber('5', showRightBorder: true),
                          ],
                        )),
                  ),
                  SizedBox(height: h(18)),
                  Padding(
                    padding: EdgeInsets.all(w(20)),
                    child: Text(
                      'Cocokkan hewan dengan angka!',
                      style: TextStyle(
                        fontSize: sp(16),
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                      ),
                    ),
                  ),
                  buildAnimalRows(),
                  SizedBox(height: h(10)),
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
                    await DBHive.unlockNextLevel(1);

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
