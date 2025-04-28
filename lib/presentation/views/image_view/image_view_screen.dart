import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class ImageViewScreen extends StatefulWidget {
  final String base64Image;

  const ImageViewScreen({Key? key, required this.base64Image})
    : super(key: key);

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(title: Text("Processed Image")),
      body: Stack(
        children: [
          PanoramaViewer(
            minLatitude: 0,
            maxLatitude: 0,
            sensorControl: SensorControl.none,
            child: Image.memory(base64Decode(widget.base64Image)),
          ),
          Container(height: 100, color: Colors.white),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: 100, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
