import 'package:flutter/material.dart';

class KeyboardKoordinat extends StatelessWidget {
  final Function(String) onKeyTap;

  final Map<String, GlobalKey>? keyMap;

  const KeyboardKoordinat({
    super.key,
    required this.onKeyTap,
    this.keyMap,
  });

  @override
  Widget build(BuildContext context) {
    List<String> row1 = ['1', '2', '3', '4', '5'];
    List<String> row2 = ['A', 'B', 'C', 'D', 'E',]; 

    return Container(
      padding: EdgeInsets.only(bottom: 18, top: 18, right: 10, left: 0),
      color: const Color(0xFFF7F7F7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                /// BARIS ANGKA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row1.map((key) => _keyButton(key)).toList(),
                ),
                const SizedBox(height: 10),
                /// BARIS HURUF
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row2.map((key) => _keyButton(key)).toList(),
                ),
              ],
            ),
          ),

          /// BACKSPACE
          GestureDetector(
            onTap: () => onKeyTap('←'),
            child: Container(
              width: 55,
              height: 105,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082),
                border: Border.all(color: Colors.orangeAccent, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/backspace.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _keyButton(String key) {
  return GestureDetector(
    key: keyMap?[key],
    onTap: () => onKeyTap(key),
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE082),
        border: Border.all(color: Colors.orangeAccent, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          key,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ),
    ),
  );
}
}