import 'package:flutter/material.dart';

const double minWidth = 920.0;

// Actual Screen Size
screenSize(context) {
  var screenSize = MediaQuery.of(context).size;
  return screenSize;
}

mobile(context) {
  bool mobile = (mobileResolution(context))
      ? true
      : screenSize(context).width <= minWidth
          ? true
          : false;

  return mobile;
}

mobileResolution(context) {
  // double verRes = screenSize(context).height / screenSize(context).width;
  double horRes = screenSize(context).width / screenSize(context).height;

  double minAspectWidth = 1024;
  double aspectRatio = minAspectWidth / 768;

  bool isMobile =
      (screenSize(context).width <= minAspectWidth && horRes >= aspectRatio)
          ? true
          : false;
  return isMobile;
}
