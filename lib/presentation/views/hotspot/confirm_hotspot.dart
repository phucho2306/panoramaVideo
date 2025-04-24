import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../select/show_model_type.dart';

class ConfirmHotsPot extends StatefulWidget {
  const ConfirmHotsPot({super.key, this.title, this.imagePath});
  final String? title;
  final String? imagePath;


  @override
  ConfirmHotsPotState createState() => ConfirmHotsPotState();
}

class ConfirmHotsPotState extends State<ConfirmHotsPot> {
  Image image = Image.file(File(''));
  PanoramaController controller = PanoramaController();
  final ImagePicker picker = ImagePicker();
  bool _isFullScreen = false; // screnn
  String imagePath = '';

  List<Hotspot> hotspot = [];
  double _lon = 0;
  double _lat = 0;
  double _tilt = 0;

  bool _showIcon = true; //icon hotspot
  bool _showBottomButtons = false; // show back and add here
  bool _showIconFullScreen = true; // icon fullscreen
  bool _buttonModel = true; // hand and Drag..
  String? selectedRoom;

  void pickImage() async {
    final XFile? galleryImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = Image.file(File(galleryImage?.path ?? ""));
      imagePath = galleryImage?.path ?? "";
    });
  }


  void resetState() {
    setState(() {
      _showBottomButtons = true;
      _isFullScreen = true;
      _showIconFullScreen = false;
      _showIcon = true;
      _buttonModel = true;
    });
  }

  void createHotspot(longitude, latitude, tilt) {
    setState(() {
      hotspot.add(Hotspot(
        longitude: longitude,
        latitude: latitude,
        width: 130,
        height: 130,
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
             'assets/images/Property1=Variant6.svg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 1),
            Text(
              'Go ${selectedRoom ?? ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white, // Hoặc màu khác tùy theo nền
              ),
            ),
          ],
        ),
      ));
    });
  }

  void onViewChanged(longitude, latitude, tilt) {
    setState(() {
      _lon = longitude;
      _lat = latitude;
      _tilt = tilt;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    Widget panorama;
    panorama = PanoramaViewer(
      panoramaController: controller,
      animSpeed: 0,
      onViewChanged: onViewChanged,
      onLongPressStart: (longitude, latitude, tilt) =>
          print('onLongPressStart: $longitude, $latitude, $tilt'),
      onLongPressMoveUpdate: (longitude, latitude, tilt) =>
          print('onLongPressMoveUpdate: $longitude, $latitude, $tilt'),
      onLongPressEnd: (longitude, latitude, tilt) =>
          print('onLongPressEnd: $longitude, $latitude, $tilt'),
      hotspots: hotspot,
      child: imagePath.isNotEmpty ? Image.file(File(imagePath)) : image,
    );

    return Scaffold(
      body: Stack(
        children: [
          panorama,
          if (!_isFullScreen) ...[
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.black.withOpacity(0.3),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/Button.svg',
                            width: 40,
                            height: 40,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFCD9B4B),
                              ),
                              child: Text(
                                'Finish this Floor',
                                style: TextStyle(color: Color(0xFFFFFFFF)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row 2 (mới thêm)
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //
                      //     Icon(Icons.info_outline, color: Colors.white),
                      //     SizedBox(width: 10),
                      //     Text(
                      //       'You have stop at this room',
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //     SizedBox(width: 83),
                      //     Icon(Icons.accessibility_new)
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCD9B4B),
                      side: BorderSide(color: Colors.white, width: 4),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                    onPressed: () {
                      showModelType(context, (roomValue) {
                        setState(() {
                          selectedRoom = roomValue;
                        });
                        resetState(); // Sử dụng hàm resetState
                      }, imagePath);
                    },
                    child: Text(
                      'ADD A NEW STOP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCD9B4B),
                        side: BorderSide(color: Color(0xFFFFFFFF), width: 4),
                        padding: EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        pickImage();
                      },
                      child: Icon(Icons.image, color: Colors.white, size: 30),
                    ),
                  ),




                  if (!_isFullScreen)
                    Positioned(
                      right: 20,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFCD9B4B),
                          side: BorderSide(color: Color(0xFFFFFFFF), width: 4),
                          padding: EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          setState(() {
                            _isFullScreen = true;
                          });
                        },
                        child: Icon(Icons.fullscreen, color: Colors.white, size: 30),
                      ),
                    ),
                ],
              ),
            ),




            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  color: Colors.black.withOpacity(0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Text(
                      'You have completed 1/3 of the room',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],




          if (_isFullScreen && _showIconFullScreen)
            Positioned(
              bottom: 80,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCD9B4B),
                  side: BorderSide(color: Colors.white, width: 4),
                  padding: EdgeInsets.all(16),
                ),
                onPressed: () {
                  setState(() {
                    _isFullScreen = false;
                    _showIconFullScreen = true;
                  });
                },
                child: Icon(Icons.fullscreen_exit, color: Colors.white, size: 30),
              ),
            ),



          if (_showBottomButtons && _buttonModel)
            Positioned(
              top: 100,
              right: 65,
              left: 65,
              child: Card(
                color: Colors.black.withOpacity(0.3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Text(
                    'Drag .... to the position you want',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),


          if (_showBottomButtons && _buttonModel)
            Positioned(
              top: 150,
              left: 170,
              right: 170,
              child: Card(
                color: Colors.black.withOpacity(0.3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: SvgPicture.asset(
                    'assets/images/tabler_hand-move.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
            ),


          if (_showBottomButtons && _showIcon)
            Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/images/Property1=Point.svg',
                width: 100,
                height: 100,
              ),
            ),
          if (_showBottomButtons && _buttonModel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4435,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Back', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF00284B),
                            side: BorderSide(color: Color(0xFF00284B), width: 1),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          ),
                        ),
                      ),




                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4435,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showIcon = false;
                              _buttonModel = false;
                              _showIconFullScreen = true;
                              _isFullScreen = false;
                            });
                            createHotspot(_lon, _lat, _tilt);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFFFFFFFF),
                            backgroundColor: Color(0xFF00284B),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text('Add Here', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}