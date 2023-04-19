import 'package:dio/dio.dart';

final Dio dio = Dio();

Future<String> parseJson(data) {
  return Future.value('');
}

void initGlobals() {
  dio.options = BaseOptions(
    responseDecoder: (responseBytes, options, responseBody) {
      return 'Fake data';
    },
  );
  dio.transformer = BackgroundTransformer()..jsonEncodeCallback = parseJson;
}
