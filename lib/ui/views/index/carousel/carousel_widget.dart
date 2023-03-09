import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../services/graphql_config.dart';
import 'carousel_slide.dart';

class CarouselPromos extends StatefulWidget {
  final String title;
  final dynamic items;
  final dynamic icons;

  const CarouselPromos({
    Key? key,
    required this.title,
    required this.items,
    required this.icons,
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF8AA7D2),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
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
                          children: [
                            CarouselSlider(
                                items: promos,
                                carouselController: _controller,
                                options: CarouselOptions(
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
                          ],
                        )),
                  ),
                  for (var icon in widget.icons)
                    Positioned(
                        top: icon == widget.icons.first ? 0 : null,
                        right: icon != widget.icons.last &&
                                icon != widget.icons.first
                            ? 0
                            : null,
                        bottom: icon == widget.icons.last ? 0 : null,
                        child: Image.network(setPath(icon['attributes']['url']),
                            width: 50))
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
