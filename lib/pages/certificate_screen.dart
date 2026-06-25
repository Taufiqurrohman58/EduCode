import 'package:flutter/material.dart';
import './db/db_hive.dart';

class CertificatePage extends StatelessWidget {
  const CertificatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3FFB4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Download Sertifikat",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                int gameProgress = DBHive.getTotalGameProgress();

                int percent = ((gameProgress / 40) * 100).toInt();

                return Text(
                  "Progress: $percent%",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 102, 102, 102),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: 0.4,
              child: Container(
                width: 250,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/images/sertifikat.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Sertifikat akan tersedia setelah progress 100%",
              style: TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 102, 102, 102),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
