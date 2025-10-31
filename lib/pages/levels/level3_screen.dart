import 'package:flutter/material.dart';
import 'level4_screen.dart';
import '../services/sound_manager.dart';

class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});

  @override
  State<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen>
with SingleTickerProviderStateMixin {
  final Map<String, String> correctMapping = {
    'apple.png': '1',
    'orange.png': '2',
    'grapes.png': '3',
    'mango.png': '4',
    'bananas.png': '5',
    'watermelon.png': '6',
  };

  Map<String, String?> droppedFruits = {
    '1': null,
    '2': null,
    '3': null,
    '4': null,
    '5': null,
    '6': null,
  };

  List<String> availableFruits = [
    'apple.png',
    'orange.png',
    'grapes.png',
    'mango.png',
    'bananas.png',
    'watermelon.png',
  ];

  late AnimationController _controller;

  String? lastCheckedStatus;
  bool hasWon = false;

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

  bool get allDropped => !droppedFruits.values.contains(null);

  void restartLevel(){
    setState((){
      droppedFruits = {
        '1': null,
        '2': null,
        '3': null,
        '4': null,
        '5': null,
        '6': null,
      };
      availableFruits = [
        'apple.png',
        'orange.png',
        'grapes.png',
        'mango.png',
        'bananas.png',
        'watermelon.png',
      ];
      lastCheckedStatus = null;
      hasWon = false;
    });
  }

  Future<void> showResultDialog(bool isCorrect) async {
    await showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isCorrect ? Icons.emoji_emotions : Icons.sentiment_dissatisfied,
                color: isCorrect ? Colors.green : Colors.red,
                size: 36,
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? "Selamat!" : "Yahh Salah",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            isCorrect
            ? "Kamu berhasil mencocokkan semua dengan benar! "
            : "Jawabanmu masih salah, coba lagi ya!",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isCorrect ? "Oke" : "Ulangi",
              style: const TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void autoCheckAnswers() async {
    if (!allDropped || hasWon) return;

    bool allCorrect = true;
    for (var entry in droppedFruits.entries) {
      final fruit = entry.value;
      if (fruit == null || correctMapping[fruit] != entry.key){
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

  Widget fruitIcon(String assetName, String label) {
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
    final isCorrect = droppedFruits[number] != null && correctMapping[droppedFruits[number]] == number;
    return Expanded(
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          final fruit = details.data;
          setState(() {
            if (droppedFruits[number] != null) {
              if (!availableFruits.contains(droppedFruits[number]!)) {
                availableFruits.add(droppedFruits[number]!);
              }
            }
            droppedFruits.updateAll((key, value) {
              if (value == fruit) return null;
              return value;
            });

            droppedFruits[number] = fruit;
            availableFruits.remove(fruit);
          });

          Future.delayed(const Duration(milliseconds: 300), autoCheckAnswers);
        },
        builder: (context, candidateData, rejectedData) {
          final droppedFruit = droppedFruits[number];
          final isFilled = droppedFruit != null;

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
              border: Border.all(
                color: borderColor, 
                width: 2
              ),
            ),
            child: Center(
              child: droppedFruit == null
                ? Text(
                  number,
                  style: const TextStyle(
                    fontSize: 48, 
                    fontWeight: FontWeight.w600
                  ),
                )
                : Draggable<String>(
                  data: droppedFruit,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/$droppedFruit',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      'assets/images/$droppedFruit',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  onDragCompleted: () {
                    setState(() {
                      droppedFruits[number] = null;
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final fruit = droppedFruits[number];
                        if (fruit != null) {
                          if (!availableFruits.contains(fruit)) {
                            availableFruits.add(fruit);
                          }
                          droppedFruits[number] = null;
                          lastCheckedStatus = null;
                          hasWon = false;
                        }
                      });
                    },
                    child: Image.asset(
                      'assets/images/$droppedFruit',
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

  Widget dashedFruit(String assetName) {
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
          border: Border.all(
            color: Colors.grey, 
            width: 1.5
          ),
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

  Widget buildFruitRows() {
    final topRow = availableFruits.take(3).toList();
    final bottomRow = availableFruits.skip(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: topRow.map((a) => dashedFruit(a)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: bottomRow.map((a) => dashedFruit(a)).toList(),
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
                                AudioManager().playVoice('sounds/level_3&4.mp3');
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
                        fruitIcon('apple.png', '1'),
                        fruitIcon('orange.png', '2'),
                        fruitIcon('grapes.png', '3'),
                        fruitIcon('mango.png', '4'),
                        fruitIcon('bananas.png', '5'),
                        fruitIcon('watermelon.png', '6'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Container(
                      decoration:BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                      child: Row(
                        children: [ 
                          boxedNumber('3'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('5'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('6'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                      child: Row(
                        children: [
                          boxedNumber('1'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('2'),
                          Container(width: 1, height: 100, color: Colors.black),
                          boxedNumber('4'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Cocokkan buah dengan angka!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  buildFruitRows(),

                  const SizedBox(height: 100),
                ],
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Level4Screen()),
              );
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
                horizontal: 20, 
                vertical: 12
              ),
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
