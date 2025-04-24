import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

Future<String?> showStopNotifyBottomSheet({
  required BuildContext context,
  required File videoFile,
  required List<CameraDescription> cameras,
  required CameraController cameraController,
}) {
  final screenHeight = MediaQuery.of(context).size.height;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (context) {
      return Container(
        height: screenHeight * 0.5,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/images/Icon.svg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Complete the Video\n Recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Intel',
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00294D),
              ),
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Confirm your use of this video to create your \nimmersive 360 tour.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Color(0xFF00284B),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 179,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, 'Preview');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00284B),
                      side: const BorderSide(color: Color(0xFF00284B), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 185,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, 'Confirm');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00284B),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'Confirm to Use',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
