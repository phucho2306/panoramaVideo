import 'package:flutter/material.dart';
import 'package:panorama_capture/presentation/views/select/show_model_type.dart';





void showModelNextRoom (context, Function(String) callBack, String path) {
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
        children: [
          Row(
            children: [
              IconButton(onPressed: () {
                Navigator.pop(context);
                showModelType(context, callBack, path);
              },
                icon: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF00284B),
                ),
              ),
              const Text(

                "Select the Next Room",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00284B)
                ),
              ),

            ],
          ),

          const SizedBox(height: 16),
          const Text("Choose a new room or reconnect to the room you have scanned:",style: TextStyle(color: Color(0xFF345470),fontSize: 14),),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00284B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: const Color(0xFF00284B),
              ),
              onPressed: () {
                Navigator.pop(context);
                callBack('Bedroom'); // Kích hoạt callback
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => ConfirmAddHotspot(imagePath: path))
                // );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.meeting_room, size: 20,color: Color(0xFFCD9B4B)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Bedroom',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),

            ),
          ),

          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00284B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: const Color(0xFF00284B),
              ),
              onPressed: () {
                Navigator.pop(context);
                callBack('Living room');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.meeting_room, size: 20,color: Color(0xFFCD9B4B),),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Living room',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),

            ),
          ),

          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00284B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: const Color(0xFF00284B),
              ),
              onPressed: () {
                Navigator.pop(context);
                callBack('Bath room');

              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.meeting_room, size: 20,color: Color(0xFFCD9B4B)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Bathroom',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  Icon(Icons.chevron_right),
                ],
              ),

            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00284B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: const Color(0xFF00284B),
              ),
              onPressed: () {
                Navigator.pop(context);
                callBack('Kitchen');

                // Navigator.push(
                //     context ,
                //     MaterialPageRoute(builder: (context) => ConfirmAddHotspot(imagePath: path)
                //     )
                // );
               // confirmAddHotspot(context, callBack);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.meeting_room, size: 20,color: Color(0xFFCD9B4B)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kitchen',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    const SizedBox(width: 100),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCD9B4B), // Màu nút
                       // padding: const EdgeInsets.all(1), // Giảm padding cho nút nhỏ
                        minimumSize: Size(70, 16), // Kích thước tối thiểu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      onPressed: () {
                        print("Edit Kitchen clicked");
                      },
                      child: Text('link back',style: TextStyle(color: Color(0xFFFFFFFF)),),
                    ),
                  ],

                    ),
                  Icon(Icons.chevron_right,size: 20,),
                ],
              ),

            ),
          ),

          SizedBox(height: 30,)
        ],
      ),
    ),
  );

}