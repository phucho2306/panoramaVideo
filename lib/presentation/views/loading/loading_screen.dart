import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubits/loading_cubit.dart';
import '../image_view/image_view_screen.dart';

class LoadingScreen extends StatelessWidget {
  final File videoFile;

  const LoadingScreen({Key? key, required this.videoFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return BlocProvider(
      create: (context) => LoadingCubit(videoFile: videoFile),
      child: BlocListener<LoadingCubit, LoadingState>(
        listener: (context, state) {
          if (state is LoadingSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ImageViewScreen(base64Image: state.base64Image)),
            );
          } else if (state is LoadingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        child: WillPopScope(
          onWillPop: () async {
            // Restore status bar when leaving the screen
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              centerTitle: true,
              title: const Text(
                '360 ROOM SCAN',
                style: TextStyle(
                  color: Color(0xFF00294D),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Inter',
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black87),
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
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
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
                                style: TextStyle(fontSize: 16, color: Color(0xFF00284B), fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 600,
                                    height: 300,
                                    child: Lottie.asset(
                                      'packages/panorama/assets/lotte/TFOYB36zfH.json',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'packages/panorama/assets/images/Icons.svg',
                                    width: 300,
                                    height: 130,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 0),
                              const Text(
                                'Creating 360 Room Image ...',
                                style: TextStyle(fontSize: 16, color: Color(0xFF688094)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      Container(
                        width: double.infinity,
                        height: 200,
                        padding: const EdgeInsets.only(top: 20, bottom: 40, left: 16, right: 16),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              "Feel free to return to the homepage. We'll notify you when it's completed.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, fontFamily: 'Inter', color: Color(0xFF4E6A82)),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => const ConfirmHotsPot()),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00284B),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: const RoundedRectangleBorder(),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text(
                                'BACK TO HOME SCREEN',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter'),
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
        ),
      ),
    );
  }
}
