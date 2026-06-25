import 'package:flutter/material.dart';
import './services/sound_manager.dart';
import './db/db_hive.dart';

// IMPORT MATERI
import 'materi/materi1_screen.dart';
import 'materi/materi2_screen.dart';
import 'materi/materi3_screen.dart';
import 'materi/materi4_screen.dart';
import 'materi/materi5_screen.dart';
import 'materi/materi6_screen.dart';
import 'materi/materi7_screen.dart';
import 'materi/materi8_screen.dart';
import 'materi/materi9_screen.dart';
import 'materi/materi10_screen.dart';
import 'materi/materi11_screen.dart';
import 'materi/materi12_screen.dart';
import 'materi/materi13_screen.dart';
import 'materi/materi14_screen.dart';
import 'materi/materi15_screen.dart';
import 'materi/materi16_screen.dart';
import 'materi/materi17_screen.dart';
import 'materi/materi18_screen.dart';
import 'materi/materi19_screen.dart';
import 'materi/materi20_screen.dart';
import 'materi/materi21_screen.dart';
import 'materi/materi22_screen.dart';
import 'materi/materi23_screen.dart';
import 'materi/materi24_screen.dart';
import 'materi/materi25_screen.dart';
import 'materi/materi26_screen.dart';
import 'materi/materi27_screen.dart';
import 'materi/materi28_screen.dart';
import 'materi/materi29_screen.dart';
import 'materi/materi30_screen.dart';
import 'materi/materi31_screen.dart';
import 'materi/materi32_screen.dart';
import 'materi/materi33_screen.dart';
import 'materi/materi34_screen.dart';
import 'materi/materi35_screen.dart';
import 'materi/materi36_screen.dart';
import 'materi/materi37_screen.dart';
import 'materi/materi38_screen.dart';
import 'materi/materi39_screen.dart';
import 'materi/materi40_screen.dart';


class KonsepMateriScreen extends StatefulWidget {
  final int konsepIndex;

  const KonsepMateriScreen({
    super.key,
    required this.konsepIndex,
  });

  @override
  State<KonsepMateriScreen> createState() =>
      _KonsepMateriScreenState();
}

class _KonsepMateriScreenState
    extends State<KonsepMateriScreen> {
  final _audioManager = AudioManager();

  final List<Widget> materiPages = const [
    Materi1Screen(),
    Materi2Screen(),
    Materi3Screen(),
    Materi4Screen(),
    Materi5Screen(),
    Materi6Screen(),
    Materi7Screen(),
    Materi8Screen(),
    Materi9Screen(),
    Materi10Screen(),
    Materi11Screen(),
    Materi12Screen(),
    Materi13Screen(),
    Materi14Screen(),
    Materi15Screen(),
    Materi16Screen(),
    Materi17Screen(),
    Materi18Screen(),
    Materi19Screen(),
    Materi20Screen(),
    Materi21Screen(),
    Materi22Screen(),
    Materi23Screen(),
    Materi24Screen(),
    Materi25Screen(),
    Materi26Screen(),
    Materi27Screen(),
    Materi28Screen(),
    Materi29Screen(),
    Materi30Screen(),
    Materi31Screen(),
    Materi32Screen(),
    Materi33Screen(),
    Materi34Screen(),
    Materi35Screen(),
    Materi36Screen(),
    Materi37Screen(),
    Materi38Screen(),
    Materi39Screen(),
    Materi40Screen(),
  ];

  @override
  void initState() {
    super.initState();
    _audioManager.playBackgroundMusic();
  }

  void _openMateri(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => materiPages[index],
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    int start = widget.konsepIndex * 5 + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),

      appBar: AppBar(
        title: const Text("Daftar Materi"),
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
  int materiNumber = start + i;

  bool isUnlocked =
      i == 0 ||

      /// SUDAH SELESAI
      DBHive.isMateriCompleted(
        materiNumber,
      ) ||

      /// MATERI SEBELUMNYA SELESAI
      DBHive.isMateriCompleted(
        materiNumber - 1,
      );

  return GestureDetector(
    onTap: () {
      if (!isUnlocked) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Materi masih terkunci",
            ),
          ),
        );

        return;
      }

      _openMateri(materiNumber - 1);
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
                "$materiNumber",

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
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