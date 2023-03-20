import 'package:flutter/material.dart';

class CircularContainer extends StatelessWidget {
  final Widget child;
  final Color bgColor;

  const CircularContainer({
    Key? key,
    required this.child,
    this.bgColor = const Color(0xFFD20030),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF80C2FF).withOpacity(0.75),
          border: Border.all(
              width: 25,
              color: const Color(0xFF80C2FF).withOpacity(0.35),
              strokeAlign: BorderSide.strokeAlignOutside)),
      child: Container(
          margin: const EdgeInsets.all(25),
          width: 300,
          height: 300,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                spreadRadius: -10,
                color: Colors.blue.withOpacity(0.35),
                offset: const Offset(0, 25),
              ),
              BoxShadow(
                blurRadius: 30,
                spreadRadius: -15,
                color: Colors.blue.withOpacity(0.15),
              )
            ],
            color: const Color(0xFF0272DA).withOpacity(0.50),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [child],
          )),
    );
  }
}
