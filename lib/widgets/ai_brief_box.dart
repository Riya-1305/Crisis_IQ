import 'package:flutter/material.dart';

class AIBriefBox extends StatelessWidget {
  final String brief;
  final int? generatedAt;

  const AIBriefBox({super.key, required this.brief, this.generatedAt});

  String _formatTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  size: 16, color: Color(0xFFF57F17)),
              const SizedBox(width: 6),
              const Text(
                'Gemini AI Response Brief',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF57F17),
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              if (generatedAt != null)
                Text(
                  _formatTime(generatedAt!),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            brief,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4E3400),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
