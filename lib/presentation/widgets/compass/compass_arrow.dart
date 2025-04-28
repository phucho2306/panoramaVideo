import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../cubits/compass_arrow_cubit.dart';

class CompassArrow extends StatelessWidget {
  const CompassArrow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompassArrowCubit(),
      child: BlocBuilder<CompassArrowCubit, CompassArrowState>(
        builder: (context, state) {
          if (state is CompassArrowInitial) {
            return const SizedBox.shrink();
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Slide Phone to the Right",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: Transform.rotate(
                  angle: -pi / 2,
                  child: Lottie.asset(
                    'packages/panorama/assets/lotte/Animation-1744724072689.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
