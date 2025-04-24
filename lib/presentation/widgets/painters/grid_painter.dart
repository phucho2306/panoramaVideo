import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double topOffset;
  final double bottomOffset;

  GridPainter({this.topOffset = 85.0, this.bottomOffset = 150.0}); // bạn có thể chỉnh các giá trị này

  @override
  void paint(Canvas canvas, Size size) {
    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Tính lại chiều cao có thể vẽ sau khi trừ phần top & bottom
    double gridHeight = size.height - topOffset - bottomOffset;
    double gridWidth = size.width;
    double offsetX = 0;
    double offsetY = topOffset;

    // Vẽ các đường dọc
    int columns = 3;
    double columnWidth = gridWidth / columns;
    for (int i = 1; i < columns; i++) {
      double x = columnWidth * i;
      canvas.drawLine(Offset(x, offsetY), Offset(x, offsetY + gridHeight), gridPaint);
    }

    // Vẽ các đường ngang
    int rows = 3;
    double rowHeight = gridHeight / rows;
    for (int i = 1; i < rows; i++) {
      double y = offsetY + rowHeight * i;
      canvas.drawLine(Offset(offsetX, y), Offset(offsetX + gridWidth, y), gridPaint);
    }


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
