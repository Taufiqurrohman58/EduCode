import 'package:flutter/material.dart';
import './services/sound_manager.dart';
import './db/db_hive.dart';
import 'konsep_materi_screen.dart';

class PilihMateriScreen extends StatefulWidget {
  const PilihMateriScreen({super.key});

  @override
  State<PilihMateriScreen> createState() =>
      _PilihMateriScreenState();
}

class _PilihMateriScreenState
    extends State<PilihMateriScreen> {
  final _audioManager = AudioManager();

  final List<Map<String, dynamic>> materiList = [
    {
      "title": "Encode & Decode",
      "color": Color(0xFF45B56B),
    },
    {
      "title": "Decomposition",
      "color": Color(0xFFEE3E3E),
    },
    {
      "title": "Algorithm",
      "color": Color(0xFF62B4E4),
    },
    {
      "title": "Loops",
      "color": Color(0xFF6E64AB),
    },
    {
      "title": "Sequence",
      "color": Color(0xFFF79055),
    },
    {
      "title": "Condition",
      "color": Color(0xFFE27AAF),
    },
    {
      "title": "Debugging",
      "color": Color(0xFFAC4616),
    },
    {
      "title": "Variable",
      "color": Color(0xFFFBDF64),
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioManager.playBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              "Pilih Materi",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7446EE),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: materiList.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),

                itemBuilder: (context, index) {
                  final item = materiList[index];

                  int progress =
                      DBHive.getMateriProgress(index);

                  int total = 5;

                  double percent = progress / total;

                  bool isUnlocked =
                      DBHive.isMateriKonsepUnlocked(
                    index,
                  );

                  return GestureDetector(
                    onTap: () {
                      if (!isUnlocked) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Selesaikan konsep sebelumnya dulu",
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KonsepMateriScreen(
                            konsepIndex: index,
                          ),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },

                    child: Container(
                      margin:
                          const EdgeInsets.only(bottom: 16),

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.white
                            : Colors.grey.shade200,

                        borderRadius:
                            BorderRadius.circular(18),

                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,

                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? item["color"]
                                  : Colors.grey,

                              borderRadius:
                                  BorderRadius.circular(16),
                            ),

                            child: isUnlocked
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.asset(
                                      'assets/images/gambar_org.png',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  item["title"],

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,

                                    color: isUnlocked
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,

                                  children: [
                                    const Text(
                                      "Progress Materi",
                                    ),

                                    Text(
                                      "$progress/$total",
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),

                                  child:
                                      LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 9,

                                    backgroundColor:
                                        Colors.grey[300],

                                    color: isUnlocked
                                        ? item["color"]
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Icon(
                            isUnlocked
                                ? Icons
                                    .arrow_forward_ios_rounded
                                : Icons.lock,

                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}