// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../services/resolution.dart';

class GigometerFrame extends StatelessWidget {
  final String source;
  const GigometerFrame({Key? key, required this.source}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IFrameElement iframeElement = IFrameElement()
      ..src = source
      ..style.height = '100%'
      ..style.width = '100%'
      ..style.border = 'none'
      ..setAttribute("allowtransparency", "true")
      ..onLoad.listen((event) {
        const CircularProgressIndicator();
      });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'webpage',
      (int viewId) => iframeElement,
    );

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
            height: mobile(context)
                ? screenSize(context).height * 0.8
                : screenSize(context).height * 0.75,
            child: const HtmlElementView(viewType: 'webpage')),
        PointerInterceptor(
          intercepting: true,
          debug: false,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: mobile(context)
                  ? (screenSize(context).height * 0.8) - 130
                  : (screenSize(context).height * 0.75) - 150,
              width: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}
