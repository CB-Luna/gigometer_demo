import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:seo/seo.dart';
import 'package:speed_test/services/index_query.dart';
import 'package:speed_test/ui/views/index/carousel/carousel_widget.dart';
import 'package:speed_test/ui/views/index/gigometer.dart';

import '../../../providers/tracking_provider.dart';
import '../../../services/project_settings.dart';
import '../../../services/resolution.dart';
import '../../widgets/graphql_call.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class IndexView extends StatelessWidget {
  const IndexView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataCall(query: queryIndex, page: viewIndex);
  }

  Widget viewIndex(QueryResult result, BuildContext context) {
    bool correctData = result.isConcrete && result.data != null;

    var viewData = result.data?['appGigometer']['data']['attributes'];

    //Frame Link
    final String gigometerLink = envRoute.contains("dev")
        ? gigometerUrl
        : "https://gigometer.net/CustomSpeedTest/";

    //Logo
    var logoElement = correctData ? viewData['Logo'] : null;

    //AdPromoElement
    var adElement = correctData ? viewData['PromoAd'] : null;

    // Dynamic Titles
    var dynamicTitles = correctData ? viewData['Titles'] : null;

    // Promos Section
    final String promosTitle = correctData ? viewData['PromosTitle'] : "";
    var promosIcons = correctData ? viewData['PromosIcons']['data'] : null;
    var promosData = correctData ? viewData['Promos'] : null;

    //Carousel Zane Section
    var carouZaneData = correctData ? viewData['CarouZane'] : null;

    const double padding = 20.0;

    const colorizeColors = [
      Colors.white,
      Color.fromARGB(255, 205, 229, 248),
      Color.fromARGB(255, 187, 215, 237),
      Color.fromARGB(255, 133, 179, 215),
    ];

    if (!correctData) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Wrap(
                    runSpacing: 10,
                    runAlignment: WrapAlignment.center,
                    alignment: mobile(context)
                        ? WrapAlignment.center
                        : WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      Padding(
                        padding: mobile(context)
                            ? const EdgeInsets.only(top: 10)
                            : const EdgeInsets.symmetric(vertical: 15),
                        child: const LinkingElement(
                          element: {
                            "Picture": {
                              "data": {
                                "attributes": {
                                  "alternativeText": "Gigometer Logo",
                                  "url": "https://i.imgur.com/xSEOZqQ.png"
                                }
                              }
                            },
                            "Link": "https://rtatel.com/",
                            "Title": "Go Now"
                          }, //logoElement,
                          constraintWidth: 85,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: padding,
                          right: padding,
                        ),
                        width: double.infinity,
                        constraints: BoxConstraints(
                            maxWidth: mobile(context)
                                ? double.infinity
                                : screenSize(context).width < 1400
                                    ? screenSize(context).width * 0.4
                                    : 550),
                        child: FractionallySizedBox(
                          widthFactor: mobile(context) ? 0.7 : 1,
                          child: SizedBox(
                            height: mobile(context)
                                ? 25
                                : screenSize(context).height * 0.15,
                            child: FittedBox(
                              child: Seo.text(
                                style: TextTagStyle.h1,
                                text:
                                    "Welcome to the gigometer", //dynamicTitles.first['Text'],
                                child: AnimatedTextKit(
                                    pause: const Duration(milliseconds: 100),
                                    repeatForever: true,
                                    animatedTexts: [
                                      for (var text in [
                                        {"Text": "Welcome to the gigometer"},
                                        {"Text": "Test your gig speed"}
                                      ])
                                        ColorizeAnimatedText(
                                          text['Text']!,
                                          textAlign: TextAlign.center,
                                          // duration:
                                          //     const Duration(milliseconds: 4000),
                                          colors: colorizeColors,
                                          textStyle:
                                              GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  letterSpacing: -0.5,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14),
                                        ),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: SizedBox(
                              width: screenSize(context).width * 0.15)),
                    ],
                  ),
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: mobile(context)
                      ? WrapAlignment.center
                      : WrapAlignment.spaceBetween,
                  children: [
                    FractionallySizedBox(
                      widthFactor: mobile(context) ? 1.0 : 0.4,
                      child: GigometerFrame(source: gigometerLink),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget merchPromo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinkingElement(element: adElement),
        Container(
          margin: EdgeInsets.all(mobile(context) ? 10 : 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromARGB(255, 255, 248, 150)),
          constraints: BoxConstraints(
              maxHeight: mobile(context) ? 40 : 25,
              maxWidth: mobile(context) ? double.infinity : 200),
          child: Marquee(
            text: adElement['Picture']['data']['attributes']['alternativeText'],
            style: GoogleFonts.plusJakartaSans(
              color: Colors.black,
              fontSize: mobile(context) ? 28 : 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.25,
            ),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 10.0,
            velocity: 50.0,
            startPadding: 10.0,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Wrap(
                  runSpacing: 10,
                  runAlignment: WrapAlignment.center,
                  alignment: mobile(context)
                      ? WrapAlignment.center
                      : WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    Padding(
                      padding: mobile(context)
                          ? const EdgeInsets.only(top: 10)
                          : const EdgeInsets.symmetric(vertical: 15),
                      child: LinkingElement(
                        element: logoElement,
                        constraintWidth: 85,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: padding,
                        right: padding,
                      ),
                      width: double.infinity,
                      constraints: BoxConstraints(
                          maxWidth: mobile(context)
                              ? double.infinity
                              : screenSize(context).width < 1400
                                  ? screenSize(context).width * 0.4
                                  : 550),
                      child: FractionallySizedBox(
                        widthFactor: mobile(context) ? 0.7 : 1,
                        child: SizedBox(
                          height: mobile(context)
                              ? 25
                              : screenSize(context).height * 0.15,
                          child: FittedBox(
                            child: Seo.text(
                              style: TextTagStyle.h1,
                              text: dynamicTitles.first['Text'],
                              child: AnimatedTextKit(
                                  pause: const Duration(milliseconds: 100),
                                  repeatForever: true,
                                  animatedTexts: [
                                    for (var text in dynamicTitles)
                                      ColorizeAnimatedText(
                                        text['Text'],
                                        textAlign: TextAlign.center,
                                        // duration:
                                        //     const Duration(milliseconds: 4000),
                                        colors: colorizeColors,
                                        textStyle: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14),
                                      ),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child:
                            SizedBox(width: screenSize(context).width * 0.15)),
                  ],
                ),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: mobile(context)
                    ? WrapAlignment.center
                    : WrapAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: !mobile(context),
                    child: FractionallySizedBox(
                      widthFactor: mobile(context) ? 1.0 : 0.3,
                      child: CarouselPromos(title: "", items: carouZaneData),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: mobile(context) ? 1.0 : 0.4,
                    child: GigometerFrame(source: gigometerLink),
                  ),
                  FractionallySizedBox(
                    widthFactor: mobile(context) ? 0.80 : 0.3,
                    child: CarouselPromos(
                      title: promosTitle,
                      items: promosData,
                      icons: promosIcons,
                    ),
                  ),
                  Visibility(
                      visible: mobile(context),
                      child: FractionallySizedBox(
                          widthFactor: 0.8, child: merchPromo)),
                  Visibility(
                      visible: mobile(context),
                      child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child:
                              CarouselPromos(title: "", items: carouZaneData))),
                ],
              ),
            ],
          ),
          if (!mobile(context)) merchPromo,
        ],
      ),
    );
  }
}

class LinkingElement extends StatelessWidget {
  const LinkingElement({
    super.key,
    required this.element,
    this.constraintWidth,
  });

  final dynamic element;
  final double? constraintWidth;

  @override
  Widget build(BuildContext context) {
    final dynamic picture = element['Picture']['data']['attributes'];
    final String link = element['Link'];

    var tracking = Provider.of<TrackingProvider>(context);

    return Seo.link(
      anchor: element['Link'],
      href: element['Link'],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            html.window.open(link, "");
            tracking.recordTrack(element['Link']);
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth:
                    mobile(context) ? constraintWidth ?? double.infinity : 170),
            child: Seo.image(
              alt: picture['alternativeText'],
              src: picture["url"].contains("imgur")
                  ? picture['url']
                  : setPath(picture['url']),
              child: Image.network(
                  picture["url"].contains("imgur")
                      ? picture['url']
                      : setPath(picture['url']),
                  width: mobile(context)
                      ? null
                      : screenSize(context).width * 0.15),
            ),
          ),
        ),
      ),
    );
  }
}
