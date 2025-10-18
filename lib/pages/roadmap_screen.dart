import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';
import 'db/db_helper.dart';

import 'levels/level1_screen.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  List<PointModel> points = [];
  int unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      unlockedLevel = DBHelper.getUnlockedLevel();
      _generatePoints();
    });
  }

  void _generatePoints() {
    points = [];
    for (int i = 1; i <= 83; i++) {
      bool isUnlocked = i <= unlockedLevel;

      PointModel point = PointModel(
        100,
        GestureDetector(
          onTap: () {
            if (isUnlocked) {
              _navigateToLevel(i);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Level terkunci")),
              );
            }
          },
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.purpleAccent : Colors.grey.shade700,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: isUnlocked
                ? Text(
                    '$i',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(Icons.lock, color: Colors.white, size: 20),
          ),
        ),
      );

      if (i == unlockedLevel) point.isCurrent = true;
      points.add(point);
    }
  }

  void _navigateToLevel(int level) {
    Widget? page;
    switch (level) {
      case 1:
        page = const Level1Screen();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Level belum dibuat")),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page!),
    ).then((_) => _loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameLevelsScrollingMap.scrollable(
        key: ValueKey(unlockedLevel),
        imageUrl: "assets/drawable/map_vertical.png",
        svgUrl: "assets/svg/map_vertical.svg",
        direction: Axis.vertical,
        reverseScrolling: true,
        points: points,
        pointsPositionDeltaX: 30,
        pointsPositionDeltaY: 30,
      ),
    );
  }
}