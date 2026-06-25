import 'package:flutter/material.dart';

class LetterKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;

  final Map<String, GlobalKey>? keyMap;

  const LetterKeyboard({
    super.key,
    required this.onKeyTap,
    this.keyMap,
  });

  @override
  Widget build(BuildContext context) {
    List<String> row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
    List<String> row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
    List<String> row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      color: const Color(0xFFF7F7F7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWrap(row1),
          const SizedBox(height: 10),

          // Baris tengah sedikit menjorok ke dalam (biar mirip keyboard asli)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildWrap(row2),
          ),
          const SizedBox(height: 10),

          // Baris bawah + tombol delete di kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 3,
                runSpacing: 6,
                children: row3.map((k) => _keyButton(k)).toList(),
              ),
              const SizedBox(width: 8),

              // Tombol Delete
              GestureDetector(
                onTap: () => onKeyTap('←'),
                child: Container(
                  width: 40,
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE082),
                    border: Border.all(color: Colors.orangeAccent, width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.backspace,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWrap(List<String> keys) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 3,
      runSpacing: 6,
      children: keys.map((k) => _keyButton(k)).toList(),
    );
  }

Widget _keyButton(String key) {
  return GestureDetector(
    key: keyMap?[key],
      onTap: () => onKeyTap(key),
      child: Container(
        width: 30,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE082),
          border: Border.all(color: Colors.orangeAccent, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
      ),
    );
  }
}
