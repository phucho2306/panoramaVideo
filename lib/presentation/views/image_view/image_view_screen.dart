import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class ImageViewScreen extends StatefulWidget {
  final String base64Image;
  const ImageViewScreen({Key? key, required this.base64Image}) : super(key: key);

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Processed Image")),
      body: PanoramaViewer(
        child: Image.memory(base64Decode(widget.base64Image)),
      ),
    );
  }
}
