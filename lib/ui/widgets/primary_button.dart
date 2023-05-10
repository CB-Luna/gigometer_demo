import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isActive;
  final String text;
  final Color bgColor;

  const PrimaryButton({
    Key? key,
    this.onPressed,
    required this.text,
    required this.isActive,
    this.bgColor = const Color(0xFFD20030),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 10.0,
      ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              side: BorderSide(
                color: Colors.white.withOpacity(0.40),
                width: 5.0,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: isActive ? bgColor : Colors.grey,
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 30)),
          onPressed: onPressed,
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              height: 1,
              color: Colors.white.withOpacity(0.90),
              fontWeight: FontWeight.w700,
            ),
          )),
    );
  }
}
