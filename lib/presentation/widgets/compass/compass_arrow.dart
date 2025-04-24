import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CompassArrow extends StatelessWidget {
  const CompassArrow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Slide Phone to the Right", // hoặc bất kỳ nội dung nào bạn muốn
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 24,
          height: 24,
          child: Transform.rotate(
            angle: -pi / 2, // Xoay -90 độ để chuyển từ "hướng xuống" sang "hướng phải"
            child: Lottie.asset(
              'assets/lotte/Animation-1744724072689.json',
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
