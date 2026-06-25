import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PressableCircleIcon extends StatefulWidget {
  final String asset;
  final Color bgColor;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  const PressableCircleIcon({
    super.key,
    required this.asset,
    required this.bgColor,
    required this.size,
    required this.iconSize,
    this.onTap,
  });

  @override
  State<PressableCircleIcon> createState() => _PressableCircleIconState();
}

class _PressableCircleIconState extends State<PressableCircleIcon> {
  double scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => scale = 0.85);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              widget.asset,
              width: widget.iconSize,
              height: widget.iconSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}