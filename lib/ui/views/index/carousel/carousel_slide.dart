import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../../widgets/primary_button.dart';

class CarouselSlide extends StatelessWidget {
  final dynamic promo;

  const CarouselSlide({
    Key? key,
    required this.promo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            promo['Title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              promo['Paragraph'],
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          for (var button in promo['Buttons'])
            SizedBox(
              width: 150,
              child: FittedBox(
                child: PrimaryButton(
                  text: button['Text'],
                  onPressed: () => html.window.open(button['Link'], ""),
                  isActive: true,
                  bgColor: const Color(0xFF25CB8E),
                ),
              ),
            )
        ],
      ),
    );
  }
}
