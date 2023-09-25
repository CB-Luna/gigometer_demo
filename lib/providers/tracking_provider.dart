// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:speed_test/services/project_settings.dart';

class TrackingProvider with ChangeNotifier {
  late String userip = "not-identified";
  late String ipApi =
      "${envRoute.contains("dev") ? apiEnvDev : apiEnvProd}/ipfy";

  TrackingProvider() {
    getIPAddress();
  }

  Future<String> recordTrack(String button) async {
    final Map<String, dynamic> body = {
      'apikey': 'svsvs54sef5se4fsv',
      'action': 'configuratorTracking',
      'transaction': userip,
      'page': "gigometer",
      'button': button,
    };

    try {
      var url = Uri.parse('$envRoute/planbuilder/api');

      final response = await http.post(
        url,
        body: jsonEncode(body),
      );

      return response.body;
    } catch (e) {
      return 'Error';
    }
  }

  getIPAddress() async {
    try {
      var response = await http.get(Uri.parse(ipApi));

      if (response.statusCode == 200) {
        response.body;

        userip = response.body;
        notifyListeners();
      } else {
        print("Couldn't reach IP address");
      }
    } catch (e) {
      print("Connection error");
    }
  }
}
