import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speed_test/services/index_query.dart';
import 'package:speed_test/ui/views/index/animated_car_widget.dart';
import 'package:speed_test/ui/views/index/carousel/carousel_widget.dart';

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

    const double minWidth = 900.0;

    // Actual Screen Size
    screenSize(context) {
      var screenSize = MediaQuery.of(context).size;
      return screenSize;
    }

    mobile(context) {
      bool mobile = screenSize(context).width < minWidth ? true : false;

      return mobile;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(viewTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  // color: const Color(0xFF001E4D),
                  color: Colors.white,
                  fontSize: mobile(context) ? 45 : 75,
                  letterSpacing: mobile(context) ? -1 : -3,
                  fontWeight: FontWeight.w800)),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: mobile(context)
                ? WrapAlignment.center
                : WrapAlignment.spaceBetween,
            children: [
              FractionallySizedBox(
                  widthFactor: mobile(context) ? 1.0 : 0.3,
                  child: const CarAnimation()),
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
