import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../db/db_hive.dart';
import '../services/sound_manager.dart';

class Level35Screen extends StatefulWidget {
  const Level35Screen({super.key});

  @override
  State<Level35Screen> createState() => _Level35ScreenState();
}

/// MODEL UNTUK CROSS (BIAR BISA FADE)
class _WrongMarker {
  Offset position;
  double opacity;

  _WrongMarker({
    required this.position,
    this.opacity = 1.0,
  });
}

class _Level35ScreenState extends State<Level35Screen>
    with SingleTickerProviderStateMixin {
  //responsive
  double scale = 1;
  double w(double size) => size * scale;
  double h(double size) => size * scale;
  double sp(double size) => size * scale;
  //end responsive
  late AnimationController _controller;

  bool hasWon = false;
  bool showWin = false;
  String? winAnimasi;

  final Set<int> foundDifferences = {};
  final List<_WrongMarker> wrongMarkersImage1 = [];
  final List<_WrongMarker> wrongMarkersImage2 = [];

  /// ZONA PERBEDAAN
  final List<_DifferenceZone> zones = const [
    _DifferenceZone(
      id: 1,
      rect: Rect.fromLTWH(0.16, 0.69, 0.07, 0.15),
    ),
    _DifferenceZone(
      id: 2,
      rect: Rect.fromLTWH(0.54, 0.24, 0.065, 0.15),
    ),
    _DifferenceZone(
      id: 3,
      rect: Rect.fromLTWH(0.595, 0.78, 0.07, 0.15),
    ),
  ];

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

  /// =========================
  /// FADE OUT CROSS
  /// =========================
  void _addWrongMarker(int imageIndex, Offset normalizedTap) {
    final marker = _WrongMarker(position: normalizedTap);

    setState(() {
      if (imageIndex == 0) {
        wrongMarkersImage1.add(marker);
      } else {
        wrongMarkersImage2.add(marker);
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      _fadeOutMarker(marker, imageIndex);
    });
  }

  void _fadeOutMarker(_WrongMarker marker, int imageIndex) async {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        marker.opacity -= 0.1;
      });
    }

    setState(() {
      if (imageIndex == 0) {
        wrongMarkersImage1.remove(marker);
      } else {
        wrongMarkersImage2.remove(marker);
      }
    });
  }

  Future<void> showResultDialog() async {
    setState(() {
      showWin = true;
      winAnimasi = 'assets/lottie/benar.json';
    });

    await AudioManager().playEffect('sounds/benar.mp3');
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      showWin = false;
    });
  }

  void _nextLevel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level 36 berhasil terbuka!')),
    );
    Navigator.pop(context);
  }

  _DifferenceZone? _hitTestDifference(Offset localPosition, Size size) {
    final normalized = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );

    for (final zone in zones) {
      if (zone.rect.contains(normalized)) {
        return zone;
      }
    }
    return null;
  }

  void _handleTap({
    required int imageIndex,
    required TapDownDetails details,
    required Size size,
  }) async {
    if (hasWon) return;

    final hitZone = _hitTestDifference(details.localPosition, size);

    if (hitZone != null && !foundDifferences.contains(hitZone.id)) {
      setState(() {
        foundDifferences.add(hitZone.id);
      });

      if (foundDifferences.length == zones.length) {
        setState(() {
          hasWon = true;
        });

        _controller.forward(from: 0);
        await showResultDialog();
      }
    } else {
      final normalizedTap = Offset(
        details.localPosition.dx / size.width,
        details.localPosition.dy / size.height,
      );

      _addWrongMarker(imageIndex, normalizedTap);
    }
  }

  Widget _markerAt({
    required Offset normalizedPosition,
    required Size size,
    required String asset,
    double markerSize = 34,
  }) {
    return Positioned(
      left: (normalizedPosition.dx * size.width) - (markerSize / 2),
      top: (normalizedPosition.dy * size.height) - (markerSize / 2),
      child: IgnorePointer(
        child: Image.asset(
          asset,
          width: w(markerSize),
          height: h(markerSize),
        ),
      ),
    );
  }

  Widget _buildImageBoard({
    required int imageIndex,
    required String asset,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width / 1.4;
        final size = Size(width, height);

        return GestureDetector(
          onTapDown: (details) => _handleTap(
            imageIndex: imageIndex,
            details: details,
            size: size,
          ),
          child: SizedBox(
            width: w(width),
            height: h(height),
            child: Stack(
              children: [
                /// GAMBAR
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(w(12)),
                    child: Image.asset(asset, fit: BoxFit.fill),
                  ),
                ),

                /// =========================
                /// DEBUG AREA (WARNA)
                /// =========================
                ...zones.map((zone) {
                  return Positioned(
                    left: zone.rect.left * size.width,
                    top: zone.rect.top * size.height,
                    width: zone.rect.width * size.width,
                    height: zone.rect.height * size.height,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  );
                }),

                /// CHECK
                ...zones
                    .where((z) => foundDifferences.contains(z.id))
                    .map((zone) => _markerAt(
                          normalizedPosition: zone.center,
                          size: size,
                          asset: 'assets/images/check.png',
                        )),

                /// CROSS IMAGE 1
                if (imageIndex == 0)
                  ...wrongMarkersImage1.map((m) => Positioned(
                        left: w((m.position.dx * size.width) - 14),
                        top: h((m.position.dy * size.height) - 14),
                        child: Opacity(
                          opacity: m.opacity,
                          child: Image.asset(
                            'assets/images/cross.png',
                            width: w(20),
                            height: h(20),
                          ),
                        ),
                      )),

                /// CROSS IMAGE 2
                if (imageIndex == 1)
                  ...wrongMarkersImage2.map((m) => Positioned(
                        left: w((m.position.dx * size.width) - 14),
                        top: h((m.position.dy * size.height) - 14),
                        child: Opacity(
                          opacity: m.opacity,
                          child: Image.asset(
                            'assets/images/cross.png',
                            width: w(20),
                            height: h(20),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea(double boardWidth) {
    return Column(
      children: [
        _buildImageBoard(
          imageIndex: 0,
          asset: 'assets/images/gambar_a.png',
        ),
        SizedBox(height: h(28)),
        _buildImageBoard(
          imageIndex: 1,
          asset: 'assets/images/gambar_b.png',
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
            LayoutBuilder(
              builder: (context, constraints) {
                final boardWidth = math.min(constraints.maxWidth * 0.92, 470.0);

                return SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w(12)),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: h(66),
                                color: const Color(0xFFAC4616),
                                alignment: Alignment.center,
                                child: Text(
                                  'DEBUGGING',
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
                                          borderRadius:
                                              BorderRadius.circular(w(8)),
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
                          SizedBox(height: h(20)),
                          const Text(
                            "Cari 3 perbedaan pada gambar dibawah ini",
                          ),
                          SizedBox(height: h(20)),
                          SizedBox(
                            width: boardWidth,
                            child: _buildGameArea(boardWidth),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (showWin && winAnimasi != null)
              Center(
                child: Lottie.asset(winAnimasi!, width: w(250)),
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
                    await DBHive.unlockNextLevel(35);

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

class _DifferenceZone {
  final int id;
  final Rect rect;

  const _DifferenceZone({
    required this.id,
    required this.rect,
  });

  Offset get center => Offset(
        rect.left + rect.width / 2,
        rect.top + rect.height / 2,
      );
}
