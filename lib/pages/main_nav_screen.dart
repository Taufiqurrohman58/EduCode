import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './services/sound_manager.dart';

// import halaman kamu
import 'home_screen.dart';
import 'progress_screen.dart';
import 'verification_screen.dart';
import 'certificate_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  final _audioManager = AudioManager();

  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ProgressPage(),
    CertificatePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const VerificationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 1); // dari bawah
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _audioManager.playBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: SizedBox(
        height: 70,
        child: Row(
          children: List.generate(4, (index) {
            final isActive = _selectedIndex == index;

            String iconPath;
            String label;

            switch (index) {
              case 0:
                iconPath = "assets/images/icons/home.svg";
                label = "Beranda";
                break;
              case 1:
                iconPath = "assets/images/icons/progress.svg";
                label = "Progres";
                break;
              case 2:
                iconPath = "assets/images/icons/certificate.svg";
                label = "Sertifikat";
                break;
              default:
                iconPath = "assets/images/icons/account.svg";
                label = "Akun";
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(index),
                child: Container(
                  color: isActive
                      ? const Color.fromARGB(255, 42, 123, 82)
                      : Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        width: 35,
                        height: 35,
                        colorFilter: ColorFilter.mode(
                          isActive
                              ? Colors.white
                              : const Color.fromARGB(255, 42, 123, 82),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : const Color.fromARGB(255, 42, 123, 82),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}