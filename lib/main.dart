import 'package:educode/pages/main_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'pages/splash_screen.dart';
import 'pages/pilih_konsep_game_screen.dart';
import 'pages/pilih_konsep_materi_screen.dart';
import 'pages/service_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/db/db_hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // kunci supaya tidak rotate
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Hive.initFlutter();
  await DBHive.init();

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
        '/main': (context) => const MainNavScreen(),
        '/pilih_level': (context) => const PilihKonsepGameScreen(),
        '/pilih_materi': (context) => const PilihMateriScreen(),
        '/service': (context) => const ServiceScreen(),
      },
    );
  }
}
