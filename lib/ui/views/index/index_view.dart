import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:seo/seo.dart';
import 'package:speed_test/services/index_query.dart';
import 'package:speed_test/ui/views/index/carousel/carousel_widget.dart';
import 'package:speed_test/ui/views/index/gigometer.dart';

import '../../../services/graphql_config.dart';
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
    var viewData = result.data?['appGigometer']['data']['attributes'];

    //Frame Link
    final String gigometerLink = viewData['ExtFrame'];

    //Logo
    var logoElement = viewData['Logo'];

    //AdPromoElement
    var adElement = viewData['PromoAd'];

    // Title
    final String viewTitle = viewData['Title'];

    // Promos Section
    final String promosTitle = viewData['PromosTitle'];
    var promosIcons = viewData['PromosIcons']['data'];
    var promosData = viewData['Promos'];

    //Carousel Zane Section
    var carouZaneData = viewData['CarouZane'];

    const double padding = 20.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Column(
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
              crossAxisAlignment: WrapCrossAlignment.center,
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
                    child: FittedBox(
                      child: Seo.text(
                        style: TextTagStyle.h1,
                        text: viewTitle,
                        child: Text(
                          viewTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!mobile(context)) LinkingElement(element: adElement),
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
                      widthFactor: 0.8,
                      child: LinkingElement(element: adElement))),
              Visibility(
                  visible: mobile(context),
                  child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: CarouselPromos(title: "", items: carouZaneData))),
            ],
          ),
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
    return Seo.link(
      anchor: element['Link'],
      href: element['Link'],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => html.window.open(link, ""),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth:
                    mobile(context) ? constraintWidth ?? double.infinity : 200),
            child: Seo.image(
              alt: picture['alternativeText'],
              src: setPath(picture['url']),
              child: Image.network(setPath(picture['url']),
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
