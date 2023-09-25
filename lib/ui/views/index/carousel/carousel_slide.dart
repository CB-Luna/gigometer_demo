import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:seo/seo.dart';
import 'package:speed_test/providers/tracking_provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../../../services/project_settings.dart';
import '../../../widgets/primary_button.dart';

class CarouselSlide extends StatelessWidget {
  final dynamic promo;

  const CarouselSlide({
    Key? key,
    required this.promo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tracking = Provider.of<TrackingProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Seo.text(
            text: promo['Title'],
            style: TextTagStyle.h3,
            child: Text(
              promo['Title'],
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
              ),
            ),
          ),
          if (promo['Media'] != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: Seo.image(
                alt: promo['Media']['data']['attributes']['alternativeText'],
                src: setPath(promo['Media']['data']['attributes']['url']),
                child: Image.network(
                  setPath(promo['Media']['data']['attributes']['url']),
                ),
              ),
            ),
          Padding(
            padding: promo['Media'] != null
                ? const EdgeInsets.only(bottom: 5.0)
                : const EdgeInsets.symmetric(vertical: 10.0),
            child: Seo.text(
              text: promo['Paragraph'],
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
          ),
          for (var button in promo['Buttons'])
            SizedBox(
              width: 125,
              child: FittedBox(
                child: Seo.link(
                  anchor: button['Link'],
                  href: button['Link'],
                  child: PrimaryButton(
                    text: button['Text'],
                    onPressed: () {
                      html.window.open(button['Link'], "");
                      tracking.recordTrack(promo['Title']);
                    },
                    isActive: true,
                    bgColor: const Color(0xFF25CB8E),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
