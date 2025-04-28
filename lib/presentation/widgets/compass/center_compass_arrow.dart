import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubits/center_compass_arrow_cubit.dart';

class CenterCompassArrow extends StatelessWidget {
  final double size;

  const CenterCompassArrow({super.key, this.size = 55});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CenterCompassArrowCubit(),
      child: BlocBuilder<CenterCompassArrowCubit, CenterCompassArrowState>(
        builder: (context, state) {
          if (state is CenterCompassArrowError) {
            return const SizedBox();
          }

          double relativeDirection = 0;
          double totalRotation = 0;
          bool isComplete = false;

          if (state is CenterCompassArrowUpdating) {
            relativeDirection = state.relativeDirection;
            totalRotation = state.totalRotation;
            isComplete = state.isComplete;
          }

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
                          width: size + 32,
                          height: size + 32,
                          child: CircularProgressIndicator(
                            value: (totalRotation.clamp(0, 360)) / 360,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete ? const Color(0xFF34C759) : const Color(0xFFFFCC00),
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: angle,
                          child: SvgPicture.asset(
                            'packages/panorama/assets/images/Group_294.svg',
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
      ),
    );
  }
}
