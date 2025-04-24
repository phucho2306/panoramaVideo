import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:panorama_capture/presentation/views/hotspot/confirm_hotspot.dart';
import '../image_view/image_view_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:flutter_svg/flutter_svg.dart';


class LoadingScreen extends StatefulWidget {
  final File videoFile;
  const LoadingScreen({Key? key, required this.videoFile}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<String?> _uploadVideo(BuildContext context) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://160.191.164.16:8234/image_stitching'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', widget.videoFile.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse['data'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Video upload failed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while uploading: $e")),
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Ẩn status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Khôi phục status bar khi rời màn hình (tùy chọn)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      String? base64Image = await _uploadVideo(context);
      if (base64Image != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewScreen(base64Image: base64Image),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Text(
            '360 ROOM SCAN',
            style: TextStyle(
              color: Color(0xFF00294D),
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Inter',
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,  // Căn trái
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,  // Căn nội dung theo chiều ngang (bên trái)
                        children: [
                          SizedBox(height: 16),
                          Text(
                            '360 Rendering',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00284B),
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please wait...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF00284B),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  // ✅ Animation section tách biệt và căn giữa theo chiều dọc
                  SizedBox(
                    height: screenHeight * 0.5, // Chiếm nửa màn hình
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Đảm bảo Column co lại theo nội dung
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 600,
                                height: 300,
                                child: Lottie.asset(
                                  'assets/lotte/TFOYB36zfH.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/images/Icons.svg',
                                width: 300,
                                height: 130,
                              ),
                            ],
                          ),
                          SizedBox(height: 0),
                          Text(
                            'Creating 360 Room Image ...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF688094),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 60,),
                  // ✅ Section dưới
                  Container(
                    width: double.infinity,
                    height: 200, // Đặt chiều cao cụ thể cho container
                    padding: EdgeInsets.only(top: 20, bottom: 40, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end, // Căn các phần tử xuống dưới
                      children: [
                        Text(
                          "Feel free to return to the homepage. We'll notify you when it's completed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            color: Color(0xFF4E6A82),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute( builder: (context) => ConfirmHotsPot())
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00284B),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(),
                            minimumSize: Size(double.infinity, 48),
                          ),
                          child: Text(
                            'BACK TO HOME SCREEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),



                ],
              ),
            );
          },
        ),
      ),
    );

  }
}
