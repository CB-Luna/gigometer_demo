import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CarAnimation extends StatefulWidget {
  const CarAnimation({
    Key? key,
  }) : super(key: key);

  @override
  State<CarAnimation> createState() => _CarAnimationState();
}

class _CarAnimationState extends State<CarAnimation> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('car');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: const SizedBox(
          width: 400,
          height: 600,
          child: RiveAnimation.asset('assets/RiveAssets/GruaRTA.riv'),
        ),
      ),
    );
  }
}
