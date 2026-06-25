import 'package:flutter/material.dart';
import './services/sound_manager.dart';
import './db/db_hive.dart';

// IMPORT LEVEL
import './levels/level1_screen.dart';
import './levels/level2_screen.dart';
import './levels/level3_screen.dart';
import './levels/level4_screen.dart';
import './levels/level5_screen.dart';
import './levels/level6_screen.dart';
import './levels/level7_screen.dart';
import './levels/level8_screen.dart';
import './levels/level9_screen.dart';
import './levels/level10_screen.dart';
import './levels/level11_screen.dart';
import './levels/level12_screen.dart';
import './levels/level13_screen.dart';
import './levels/level14_screen.dart';
import './levels/level15_screen.dart';
import './levels/level16_screen.dart';
import './levels/level17_screen.dart';
import './levels/level18_screen.dart';
import './levels/level19_screen.dart';
import './levels/level20_screen.dart';
import './levels/level21_screen.dart';
import './levels/level22_screen.dart';
import './levels/level23_screen.dart';
import './levels/level24_screen.dart';
import './levels/level25_screen.dart';
import './levels/level26_screen.dart';
import './levels/level27_screen.dart';
import './levels/level28_screen.dart';
import './levels/level29_screen.dart';
import './levels/level30_screen.dart';
import './levels/level31_screen.dart';
import './levels/level32_screen.dart';
import './levels/level33_screen.dart';
import './levels/level34_screen.dart';
import './levels/level35_screen.dart';
import './levels/level36_screen.dart';
import './levels/level37_screen.dart';
import './levels/level38_screen.dart';
import './levels/level39_screen.dart';
import './levels/level40_screen.dart';

class KonsepGameScreen extends StatefulWidget {
  final int konsepIndex;

  const KonsepGameScreen({
    super.key,
    required this.konsepIndex,
  });

  @override
  State<KonsepGameScreen> createState() =>
      _KonsepGameScreenState();
}

class _KonsepGameScreenState
    extends State<KonsepGameScreen> {
  final _audioManager = AudioManager();

  final List<Widget> levelPages = const [
    Level1Screen(),
    Level2Screen(),
    Level3Screen(),
    Level4Screen(),
    Level5Screen(),
    Level6Screen(),
    Level7Screen(),
    Level8Screen(),
    Level9Screen(),
    Level10Screen(),
    Level11Screen(),
    Level12Screen(),
    Level13Screen(),
    Level14Screen(),
    Level15Screen(),
    Level16Screen(),
    Level17Screen(),
    Level18Screen(),
    Level19Screen(),
    Level20Screen(),
    Level21Screen(),
    Level22Screen(),
    Level23Screen(),
    Level24Screen(),
    Level25Screen(),
    Level26Screen(),
    Level27Screen(),
    Level28Screen(),
    Level29Screen(),
    Level30Screen(),
    Level31Screen(),
    Level32Screen(),
    Level33Screen(),
    Level34Screen(),
    Level35Screen(),
    Level36Screen(),
    Level37Screen(),
    Level38Screen(),
    Level39Screen(),
    Level40Screen(),
  ];

  @override
  void initState() {
    super.initState();
    _audioManager.playBackgroundMusic();
  }

  void _openLevel(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => levelPages[index],
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    int start = widget.konsepIndex * 5;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),

      appBar: AppBar(
        title: const Text("Daftar Level"),
        backgroundColor: const Color(0xFF7446EE),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: GridView.builder(
          itemCount: 5,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),

          itemBuilder: (context, i) {
            int levelIndex = start + i;

            /// LEVEL PERTAMA TERBUKA
            bool isUnlocked =
                i == 0 ||

                /// LEVEL SUDAH SELESAI
                DBHive.isLevelCompleted(
                  levelIndex + 1,
                ) ||

                /// LEVEL SEBELUMNYA SUDAH SELESAI
                DBHive.isLevelCompleted(
                  levelIndex,
                );

            return GestureDetector(
              onTap: () {
                if (!isUnlocked) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Level masih terkunci",
                      ),
                    ),
                  );

                  return;
                }

                _openLevel(levelIndex);
              },

              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFF7446EE)
                      : Colors.grey.shade300,

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Center(
                  child: isUnlocked
                      ? Text(
                          "${levelIndex + 1}",

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,
                          ),
                        )
                      : const Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}