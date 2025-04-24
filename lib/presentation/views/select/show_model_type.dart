import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:panorama_capture/presentation/views/select/show_model_nextroom.dart';


void showModelType(context, Function(String) callBack, String path ) {
  showModalBottomSheet<String>(
    context: context,
    builder: (BuildContext context) => Container(

      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              IconButton(onPressed: () =>
                  Navigator.pop(context, 'Cancel'),
                  icon: Icon(Icons.arrow_back,
                  color: Color(0xFF00284B),)
              ),
              const Text(
                'Select Type to Scan',
                style: TextStyle(
                  color: Color(0xFF00284B),
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Please select the type for this stop.',
            style: TextStyle(
              color: Color(0xFF345470),
              fontSize: 14,
            //  fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),


          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00284B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: const Color(0xFF00284B),
              ),
              onPressed: () {
                Navigator.pop(context);
                showModelNextRoom(context, callBack, path);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [

                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Go to the Next Room',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00284B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: const Color(0xFF00284B),
                    backgroundColor: Colors.white.withOpacity(0.5),
                  ),
                  onPressed: null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Stay in This Room',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,

                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30,)

// const SizedBox(height: 16),
// Row(
//   mainAxisAlignment: MainAxisAlignment.end,
//   children: [
//     TextButton(
//       onPressed: () {
//         createHotspot(longitude, latitude, tilt);
//         Navigator.pop(context, 'OK');
//         print('$longitude $latitude');
//       },
//       child: const Text('OK'),
//     ),
//   ],
// ),
        ],
      ),

    ),
  );

}