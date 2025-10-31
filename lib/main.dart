import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'pages/splash_screen.dart';
import 'pages/home_screen.dart';
import 'pages/roadmap_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/db/db_hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // kunci supaya tidak rotate
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Hive.initFlutter();
  await DBHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduCode',
      theme: ThemeData(
        fontFamily: 'fredoka',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/roadmap': (context) => const RoadmapScreen(),
      },
    );
  }
}
