import 'package:flutter/material.dart';
import './db/db_hive.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> konsepList = [
      {
        "title": "Encode & Decode",
        "color": const Color(0xFF45B56B),
      },
      {
        "title": "Decomposition",
        "color": const Color(0xFFEE3E3E),
      },
      {
        "title": "Algorithm",
        "color": const Color(0xFF62B4E4),
      },
      {
        "title": "Loops",
        "color": const Color(0xFF6E64AB),
      },
      {
        "title": "Sequence",
        "color": const Color(0xFFF79055),
      },
      {
        "title": "Condition",
        "color": const Color(0xFFE27AAF),
      },
      {
        "title": "Debugging",
        "color": const Color(0xFFAC4616),
      },
      {
        "title": "Variable",
        "color": const Color(0xFFFBDF64),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Laporan Bermain"),
        centerTitle: true,
        backgroundColor: const Color(0xFF45B56B),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: konsepList.length,

        itemBuilder: (context, index) {
          final item = konsepList[index];

          /// PROGRESS GAME
          int progress =
              DBHive.getKonsepProgress(index);

          /// TOTAL LEVEL
          int total = 5;

          /// BINTANG
          int bintang =
              DBHive.getKonsepBintang(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),

            child: LevelCard(
              level: item["title"],
              color: item["color"],
              progress: progress,
              total: total,
              bintang: bintang,
              materi: item["title"],
            ),
          );
        },
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final String level;
  final Color color;
  final int progress;
  final int total;
  final int bintang;
  final String materi;

  const LevelCard({
    super.key,
    required this.level,
    required this.color,
    required this.progress,
    required this.total,
    required this.bintang,
    required this.materi,
  });

  @override
  Widget build(BuildContext context) {
    double percent = progress / total;

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Row(
        children: [
          /// BOX LEVEL
          Container(
            width: 80,
            height: 100,

            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Padding(
              padding: const EdgeInsets.all(8),

              child: Center(
                child: Text(
                  level.toUpperCase(),

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  "Tahapan",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// PROGRESS
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10),

                        child:
                            LinearProgressIndicator(
                          value: percent,
                          minHeight: 8,

                          backgroundColor:
                              Colors.grey[300],

                          color: color,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      "$progress/$total",
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// BINTANG
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "Bintang $bintang",
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// MATERI
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: Colors.red,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        "Materi $materi",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}