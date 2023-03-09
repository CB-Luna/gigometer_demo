import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RateIndicator extends StatefulWidget {
  final bool isActive;
  final bool isDone;
  final bool isDownload;
  final double rateValue;
  final Color bgColor;

  const RateIndicator({
    Key? key,
    required this.isActive,
    required this.isDone,
    required this.isDownload,
    required this.rateValue,
    this.bgColor = Colors.blue,
  }) : super(key: key);

  @override
  State<RateIndicator> createState() => _RateIndicatorState();
}

class _RateIndicatorState extends State<RateIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 15),
      decoration: BoxDecoration(
        color: widget.isActive
            ? widget.bgColor
            : widget.isDone
                ? const Color(0xFF25CB8E)
                : const Color(0xFF8AA7D2).withOpacity(0.75),
        shape: BoxShape.circle,
      ),
      child: Column(
        children: [
          Text(widget.isDownload ? "Download" : "Upload",
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AnimatedDigitWidget(
              value: widget.rateValue / 1000,
              fractionDigits: 4,
              suffix: " G",
              textStyle: GoogleFonts.workSans(
                fontSize: 26,
                height: 1,
                color: Colors.white,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
          Text(
            "${widget.rateValue.toStringAsFixed(1)} Mbps",
            style: GoogleFonts.workSans(
              fontSize: 14,
              height: 1,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}
