import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String bgImage;
  final String iconPath;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bgImage,
    required this.iconPath,
    this.onTap,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  double _offset = 0; // 👈 posisi card atas

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _offset = 4),
      onTapUp: (_) {
        setState(() => _offset = 0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _offset = 0),

      child: SizedBox(
        height: 94, // 👈 total tinggi (card + shadow space)
        width: double.infinity,

        child: Stack(
          children: [
            /// 🔥 LAYER BAWAH (TETAP)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            /// 🔥 LAYER ATAS (YANG GERAK)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              top: _offset,
              left: 0,
              right: 0,

              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: AssetImage(widget.bgImage),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      /// TEXT
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 144, 10, 0),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ICON
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          widget.iconPath,
                          height: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}