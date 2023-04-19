import 'package:dio/dio.dart';

final Dio dio = Dio();

void initGlobals() {
  dio.options = BaseOptions(
    responseDecoder: (responseBytes, options, responseBody) {
      return 'Fake data';
    },
  );
}
