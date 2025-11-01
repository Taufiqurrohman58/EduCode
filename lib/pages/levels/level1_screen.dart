import 'package:flutter/material.dart';
import 'level2_screen.dart';
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
  final Map<String, String> correctMapping = {
    'snake.png': '1',
    'zebra.png': '2',
    'cat.png': '3',
    'fish.png': '4',
    'monkey.png': '5',
    'koala.png': '6',
  };

  Map<String, String?> droppedAnimals = {
    '1': null,
    '2': null,
    '3': null,
    '4': null,
    '5': null,
    '6': null,
  };

  List<String> availableAnimals = [
    'snake.png',
    'zebra.png',
    'cat.png',
    'fish.png',
    'monkey.png',
    'koala.png',
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

  void restartLevel(){
    setState((){
      droppedAnimals = {
        '1': null,
        '2': null,
        '3': null,
        '4': null,
        '5': null,
        '6': null,
      };
      availableAnimals = [
        'snake.png',
        'zebra.png',
        'cat.png',
        'fish.png',
        'monkey.png',
        'koala.png',
      ];
      lastCheckedStatus = null;
      hasWon = false;
    });
  }

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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Level2Screen()),
    );
  }

  Widget animalIcon(String assetName, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Image.asset('assets/images/$assetName', fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        Text(
          label, 
          style: const TextStyle(fontSize: 16)
        ),
      ],
    );
  }

  Widget boxedNumber(String number) {
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
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Center(
              child: droppedAnimal == null
                  ? Text(
                      number,
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.w600),
                    )
                  : Draggable<String>(
                      data: droppedAnimal,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/images/$droppedAnimal',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          'assets/images/$droppedAnimal',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                      onDragCompleted: () {
                        setState(() {
                          droppedAnimals[number] = null;
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
                          width: 60,
                          height: 60,
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

  Widget dashedAnimal(String assetName) {
    return Draggable<String>(
      data: assetName,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(
          'assets/images/$assetName',
          width: 70,
          height: 70,
          fit: BoxFit.contain,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(
          'assets/images/$assetName',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
      ),
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/$assetName',
            fit: BoxFit.contain,
            width: 60,
            height: 60,
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
                        height: 66,
                        color: const Color(0xFF45B56B),
                        alignment: Alignment.center,
                        child: const Text(
                          'ENCODE & DECODE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 30,
                                height: 30,
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
                            padding: const EdgeInsets.only(right: 18),
                            child: GestureDetector(
                              onTap: () async {
                                AudioManager()
                                    .playVoice('sounds/level_1&2.mp3');
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        animalIcon('snake.png', '1'),
                        animalIcon('zebra.png', '2'),
                        animalIcon('cat.png', '3'),
                        animalIcon('fish.png', '4'),
                        animalIcon('monkey.png', '5'),
                        animalIcon('koala.png', '6'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Row(
                        children: [
                          boxedNumber('1'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('4'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('2'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Row(
                        children: [
                          boxedNumber('3'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('6'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('5'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Cocokkan hewan dengan angka!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  buildAnimalRows(),
                  const SizedBox(height: 100),
                ],
              ),

            ),
            if (showWin && winAnimasi != null)
            Center(
              child: Lottie.asset(
                winAnimasi!,
                width: 250,
                height: 250,
                repeat: false,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: hasWon
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await DBHelper.unlockNextLevel(1);

                    _nextLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Colors.purple,
                        width: 3,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    elevation: 6,
                  ),
                  child: Text(
                    "Lanjut",
                    style: TextStyle(
                      fontSize: 20,
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
