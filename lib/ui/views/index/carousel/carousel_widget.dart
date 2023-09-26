import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seo/seo.dart';

import '../../../../services/project_settings.dart';
import '../../../widgets/circular_container.dart';
import 'carousel_slide.dart';

class CarouselPromos extends StatefulWidget {
  final String title;
  final dynamic items;
  final dynamic icons;

  const CarouselPromos({
    Key? key,
    required this.title,
    required this.items,
    this.icons,
  }) : super(key: key);

  @override
  State<CarouselPromos> createState() => _CarouselPromosState();
}

class _CarouselPromosState extends State<CarouselPromos> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> promos = [];

    for (var promo in widget.items) {
      promos.add(CarouselSlide(promo: promo));
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Seo.text(
                text: widget.title,
                style: TextTagStyle.h2,
                child: Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.25,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  CircularContainer(
                    child: CarouselSlider(
                        items: promos,
                        carouselController: _controller,
                        options: CarouselOptions(
                          aspectRatio: 1 / 1,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                        )),
                  ),
                  if (widget.icons != null)
                    for (var icon in widget.icons)
                      Positioned(
                          top: icon == widget.icons.first ? 0 : null,
                          right: icon != widget.icons.last &&
                                  icon != widget.icons.first
                              ? 0
                              : null,
                          bottom: icon == widget.icons.last ? 0 : null,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                shape: BoxShape.circle),
                            child: Seo.image(
                              alt: icon['attributes']['alternativeText'],
                              src: setPath(icon['attributes']['url']),
                              child: Image.network(
                                  setPath(icon['attributes']['url']),
                                  width: 30),
                            ),
                          ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: promos.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      height: 10,
                      width: 10,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 20),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Colors.blue)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
