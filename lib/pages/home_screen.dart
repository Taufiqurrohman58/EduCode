import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import './services/sound_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
      _audioManager.playBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bghome.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/roadmap');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: Colors.purple, 
                      width: 3
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow, 
                      color: Colors.white, 
                      size: 28
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Mulai",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height / 2 + 60 + 50,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/title.png",
                width: 240,
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Lottie.asset(
                "assets/lottie/cat.json",
                height: math.min(MediaQuery.of(context).size.height * 0.22, 250),
                repeat: true,
                reverse: false,
                animate: true
              ),
            ),
          ),
        ],
      ),
    );
  }
}
