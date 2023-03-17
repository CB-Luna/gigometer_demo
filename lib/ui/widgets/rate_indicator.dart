import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RateIndicator extends StatefulWidget {
  final bool isActive;
  final bool isDone;
  final bool isDownload;
  final double rateValue;
  final Color bgColor;

  const RateIndicator(
      {Key? key,
      required this.isActive,
      required this.isDone,
      required this.isDownload,
      required this.rateValue,
      this.bgColor = const Color(0xFF25CB8E)})
      : super(key: key);

  @override
  State<RateIndicator> createState() => _RateIndicatorState();
}

class _RateIndicatorState extends State<RateIndicator> {
  @override
  Widget build(BuildContext context) {
    Color loadingColor = const Color.fromARGB(255, 208, 255, 170);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 15),
      decoration: BoxDecoration(
          color: widget.isDone ? widget.bgColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
              width: 10,
              color: const Color(0xFF80C2FF).withOpacity(0.35),
              strokeAlign: BorderSide.strokeAlignOutside),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: -10,
              color: widget.isActive
                  ? loadingColor.withOpacity(0.05)
                  : const Color(0xFF022251).withOpacity(0.25),
              offset: const Offset(0, 25),
            ),
            BoxShadow(
              blurRadius: 30,
              spreadRadius: -15,
              color: widget.isActive
                  ? loadingColor.withOpacity(0.25)
                  : const Color(0xFF022251).withOpacity(0.15),
            )
          ]),
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
