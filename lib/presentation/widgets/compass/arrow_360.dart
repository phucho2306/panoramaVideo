import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CenterCompassArrow extends StatefulWidget {
  final double size;

  const CenterCompassArrow({super.key, this.size = 55});

  @override
  State<CenterCompassArrow> createState() => CenterCompassArrowState();
}

class CenterCompassArrowState extends State<CenterCompassArrow> {
  double? _startDirection;
  double? _lastDirection;
  double _totalRotation = 0;
  bool _isComplete = false;
  StreamSubscription<CompassEvent>? _compassSub;

  void reset() {
    setState(() {
      _startDirection = null;
      _lastDirection = null;
      _totalRotation = 0;
      _isComplete = false;
    });
  }


  @override
  void initState() {
    super.initState();

    _compassSub = FlutterCompass.events!.listen((event) {
      double? direction = event.heading;
      if (direction == null) return;

      if (_startDirection == null) {
        _startDirection = direction;
        _lastDirection = direction;
        return;
      }

      double delta = _calculateDelta(_lastDirection!, direction);

      // 👉 Chỉ cập nhật tổng rotation khi có sự thay đổi
      _totalRotation += delta;
      _lastDirection = direction;

      // Kiểm tra đã hoàn thành đủ một vòng chiều kim đồng hồ
      if (!_isComplete && _totalRotation >= 360) {
        setState(() {
          _isComplete = true;
        });
      }

      // Nếu quay ngược lại làm xuống dưới 360 thì huỷ complete
      if (_isComplete && _totalRotation < 360) {
        setState(() {
          _isComplete = false;
        });
      }
    });
  }

  double _calculateDelta(double last, double current) {
    double delta = current - last;

    if (delta > 180) {
      delta -= 360;
    } else if (delta < -180) {
      delta += 360;
    }

    return delta;
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.heading == null) {
          return const SizedBox();
        }

        double direction = snapshot.data!.heading!;

        // ✅ Tính góc lệch so với hướng ban đầu
        double relativeDirection = (_startDirection != null)
            ? (direction - _startDirection!) % 360
            : 0;

        // 👉 Đảm bảo góc trong khoảng -180 đến 180
        if (relativeDirection > 180) relativeDirection -= 360;
        if (relativeDirection < -180) relativeDirection += 360;

        // Chuyển sang radian để xoay icon
        double angle = relativeDirection * (pi / 180);

        return Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: const Alignment(0, -0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: widget.size + 32,
                        height: widget.size + 32,
                        child: CircularProgressIndicator(
                          value: (_totalRotation.clamp(0, 360)) / 360,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isComplete ?  Color(0xFF34C759) : Color(0xFFFFCC00),
                          ),
                        ),
                      ),

                      /// ✅ Xoay icon theo hướng quay so với ban đầu
                      Transform.rotate(
                        angle: angle,
                        child: SvgPicture.asset(
                          'assets/images/Group_294.svg',
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
