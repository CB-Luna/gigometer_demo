import 'package:flutter/material.dart';

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
