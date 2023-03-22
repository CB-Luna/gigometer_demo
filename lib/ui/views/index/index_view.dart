import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speed_test/services/index_query.dart';
import 'package:speed_test/ui/views/index/car_picture_widget.dart';
import 'package:speed_test/ui/views/index/carousel/carousel_widget.dart';

import '../../../services/resolution.dart';
import '../../widgets/graphql_call.dart';
import 'gigometer.dart';

class IndexView extends StatelessWidget {
  const IndexView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataCall(query: queryIndex, page: viewIndex);
  }

  Widget viewIndex(result, context) {
    var viewData = result.data?['appGigometer']['data']['attributes'];

    // Title
    final String viewTitle = viewData['Title'];

    // Promos Section
    final String promosTitle = viewData['PromosTitle'];
    var promosIcons = viewData['PromosIcons']['data'];
    var promosData = viewData['Promos'];

    // Zane Truck Image
    final String zaneTruckImg = viewData['Image']['data']['attributes']['url'];
    const double padding = 20.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: padding, left: padding, right: padding),
            width: double.infinity,
            constraints: BoxConstraints(
                maxWidth: mobile(context)
                    ? double.infinity
                    : screenSize(context).width < 1400
                        ? screenSize(context).width * 0.4
                        : 550),
            child: FittedBox(
              child: Text(viewTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w800)),
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
                    child: CarImage(url: zaneTruckImg)),
              ),
              FractionallySizedBox(
                  widthFactor: mobile(context) ? 1.0 : 0.4,
                  child: const Gigometer()),
              FractionallySizedBox(
                  widthFactor: mobile(context) ? 0.80 : 0.3,
                  child: CarouselPromos(
                      title: promosTitle,
                      items: promosData,
                      icons: promosIcons))
            ],
          ),
        ],
      ),
    );
  }
}
