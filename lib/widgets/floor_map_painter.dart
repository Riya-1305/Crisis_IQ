import 'package:flutter/material.dart';

class FloorMapWidget extends StatelessWidget {
  final String crisisRoom;
  final int crisisFloor;

  const FloorMapWidget({
    super.key,
    required this.crisisRoom,
    required this.crisisFloor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Floor $crisisFloor — Live View',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(children: [
                    const Icon(Icons.circle, size: 6, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('Room $crisisRoom',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: CustomPaint(
                painter: _FloorPlanPainter(crisisRoom: crisisRoom),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorPlanPainter extends CustomPainter {
  final String crisisRoom;
  _FloorPlanPainter({required this.crisisRoom});

  TextPainter _tp(String text, double size, Color color,
      {bool bold = false}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Corridor strip
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.38, w, h * 0.24),
      Paint()..color = const Color(0xFFE0E0E0),
    );
    final ct = _tp('CORRIDOR', 9, Colors.grey);
    ct.layout();
    ct.paint(canvas, Offset(w / 2 - ct.width / 2, h * 0.44));

    // 6 rooms — 3 top, 3 bottom
    final rooms = [
      {'id': '01', 'x': 0.02, 'y': 0.02, 'w': 0.29, 'h': 0.33},
      {'id': '02', 'x': 0.355, 'y': 0.02, 'w': 0.29, 'h': 0.33},
      {'id': '03', 'x': 0.69, 'y': 0.02, 'w': 0.29, 'h': 0.33},
      {'id': '04', 'x': 0.02, 'y': 0.65, 'w': 0.29, 'h': 0.33},
      {'id': '05', 'x': 0.355, 'y': 0.65, 'w': 0.29, 'h': 0.33},
      {'id': '06', 'x': 0.69, 'y': 0.65, 'w': 0.29, 'h': 0.33},
    ];

    // Determine crisis room — match last 2 digits
    final suffix = crisisRoom.length >= 2
        ? crisisRoom.substring(crisisRoom.length - 2)
        : crisisRoom.padLeft(2, '0');
    final matchedId =
        rooms.any((r) => r['id'] == suffix) ? suffix : '02';

    Rect? crisisRect;

    for (final room in rooms) {
      final rect = Rect.fromLTWH(
        (room['x'] as double) * w,
        (room['y'] as double) * h,
        (room['w'] as double) * w,
        (room['h'] as double) * h,
      );
      final isCrisis = room['id'] == matchedId;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = isCrisis ? const Color(0xFFFFEBEE) : Colors.white,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = isCrisis ? Colors.red : Colors.grey[400]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCrisis ? 2 : 1,
      );

      final label = _tp(
        isCrisis ? crisisRoom : '${crisisRoom[0]}0${room['id']}',
        10,
        isCrisis ? Colors.red[800]! : Colors.grey[700]!,
        bold: isCrisis,
      );
      label.layout();
      label.paint(
        canvas,
        Offset(
          rect.center.dx - label.width / 2,
          rect.center.dy - label.height / 2,
        ),
      );

      if (isCrisis) crisisRect = rect;
    }

    // EXIT sign
    final exitRect = Rect.fromLTWH(w - 44, h * 0.4, 40, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(exitRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF1B5E20),
    );
    final et = _tp('EXIT ↑', 8, Colors.white, bold: true);
    et.layout();
    et.paint(
      canvas,
      Offset(
        exitRect.center.dx - et.width / 2,
        exitRect.center.dy - et.height / 2,
      ),
    );

    // Dashed evacuation route
    if (crisisRect != null) {
      final paint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      double x = crisisRect.right + 4;
      final y = crisisRect.center.dy;
      final endX = exitRect.left - 4;

      while (x < endX) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + 7).clamp(0, endX), y),
          paint,
        );
        x += 12;
      }

      // Arrowhead
      canvas.drawLine(
          Offset(endX - 8, y - 5), Offset(endX, y), paint);
      canvas.drawLine(
          Offset(endX - 8, y + 5), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloorPlanPainter old) =>
      old.crisisRoom != crisisRoom;
}
