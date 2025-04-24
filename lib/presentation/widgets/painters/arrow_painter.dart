import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  final Color color;
  ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    int columns = 3;
    double columnWidth = size.width / columns;

    final Paint bodyPaint = Paint()
      ..color = color
      ..strokeWidth = 4 //10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final Path path = Path();
    // Vẽ phần thân mũi tên bên trái
    path.moveTo(columnWidth / 1.2, centerY);
    path.lineTo(columnWidth, centerY);

    // Vẽ phần thân bên phải
    path.moveTo(columnWidth * 2, centerY);
    path.lineTo(columnWidth * 2.2, centerY);

    canvas.drawPath(path, bodyPaint);

  }


  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
