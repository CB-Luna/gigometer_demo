import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:http_parser/http_parser.dart';

import 'package:speed_test/helpers/constants.dart';
import 'package:speed_test/helpers/globals.dart';

class GigometerProvider extends ChangeNotifier {
  double downloadRate = 0;
  double uploadRate = 0;

  bool readyToTest = false;
  bool loadingDownload = false;
  bool loadingUpload = false;

  Artboard? artboardRive;
  StateMachineController? stateMachineController;
  SMIInput<bool>? exitDownload;
  SMIInput<bool>? exitUpload;
  SMIInput<double>? speed;
  bool downloadDone = false;

  Artboard? artboardLoadingRive;
  StateMachineController? stateMachineLoadingController;
  SMIInput<bool>? exitLoading;

  final Random randomGenerator = Random();
  List<double> downloadSpeedsList = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  List<double> uploadSpeedsList = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  Timer? downloadTimer;
  Timer? uploadTimer;

  Future<void> loadGigometerAsset() async {
    final ByteData data =
        await rootBundle.load('assets/RiveAssets/GigOmeter.riv');

    final file = RiveFile.import(data);

    final artboard = file.mainArtboard;

    stateMachineController =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (stateMachineController != null) {
      artboard.addController(stateMachineController!);

      speed = stateMachineController!.findInput('speed');
      exitDownload = stateMachineController!.findInput('exitDownload');
      exitUpload = stateMachineController!.findInput('exitUpload');

      speed!.change(0);
      exitDownload!.change(true);
      exitUpload!.change(true);

      setInputsUpload(uploadRate, true);
    }

    artboardRive = artboard;
  }

  Future<void> loadCarAsset() async {
    final ByteData data =
        await rootBundle.load('assets/RiveAssets/LoadingCar.riv');
    final file = RiveFile.import(data);

    final artboard = file.mainArtboard;

    stateMachineLoadingController =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (stateMachineLoadingController != null) {
      artboard.addController(stateMachineLoadingController!);
      exitLoading = stateMachineLoadingController!.findInput('exit');
      exitLoading!.change(true);
    }

    artboardLoadingRive = artboard;
  }

  Future<void> loadAssets() async {
    await loadGigometerAsset();
    await loadCarAsset();
    readyToTest = true;
    notifyListeners();
  }

  Future<void> getSpeeds() async {
    await testDownloadSpeed();
    await testUploadSpeed();
  }

  Future<void> stopTest() async {}

  double getAverageSpeed(List<double> speeds) {
    double average = 0.0;
    for (var speed in speeds) {
      average += speed;
    }
    return average;
  }

  void startDownloadTimer() {
    downloadTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      downloadRate = getAverageSpeed(downloadSpeedsList);
      setInputsDownload(downloadRate, false);
    });
  }

  void startUploadTimer() {
    uploadTimer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      uploadRate = getAverageSpeed(uploadSpeedsList);
      setInputsUpload(uploadRate, false);
    });
  }

  List<int> generateRandomBytes(int bytes) {
    return List<int>.generate(bytes, (i) => randomGenerator.nextInt(256));
  }

  Future<void> testDownloadSpeed() async {
    downloadDone = false;
    loadingDownload = true;
    setInputsDownload(0, false);
    setInputLoading(false);

    final cancelToken = CancelToken();
    final List<bool> requestIsFinished = [
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    bool allRequestsFinished = false;

    startDownloadTimer();

    var totalStopwatch = Stopwatch()..start();
    for (var i = 0; i < 6; i++) {
      final randomDouble = randomGenerator.nextDouble().toStringAsFixed(16);
      var requestStopwatch = Stopwatch()..start();
      dio.get(
        '$serverUrl/downloading?n=$randomDouble',
        cancelToken: cancelToken,
        onReceiveProgress: (actualBytes, totalBytes) async {
          //Se convierten bytes a bits, luego a megabits y luego a Mbps
          downloadSpeedsList[i] = ((actualBytes * 8) / 1000000) /
              (requestStopwatch.elapsed.inMilliseconds / 1000);
        },
      ).then<Response<dynamic>?>((_) {
        requestIsFinished[i] = true;
        requestStopwatch.stop();
        return null;
      }).catchError((err) async {
        requestStopwatch.stop();
        if (CancelToken.isCancel(err)) {
          print('Request canceled: ${err.message}');
        } else {
          print(err);
        }
        return null;
      });
      await Future.delayed(const Duration(milliseconds: 100));
    }

    while (
        totalStopwatch.elapsed.inSeconds < 15 && allRequestsFinished == false) {
      allRequestsFinished =
          requestIsFinished.every((element) => element == true);
      await Future.delayed(const Duration(seconds: 1));
    }

    totalStopwatch.stop();
    cancelToken.cancel('Cancelled');
    downloadTimer?.cancel();

    downloadRate = getAverageSpeed(downloadSpeedsList);

    await Future.delayed(const Duration(seconds: 1));

    setInputsDownload(downloadRate, true);

    loadingDownload = false;
    downloadDone = true;

    notifyListeners();
  }

  Future<void> testUploadSpeed() async {
    loadingUpload = true;
    setInputsUpload(0, false);
    setInputLoading(false);

    final cancelToken = CancelToken();
    final List<bool> requestIsFinished = [
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    bool allRequestsFinished = false;

    final List<int> data = generateRandomBytes(1 * 1000000);

    startUploadTimer();

    var totalStopwatch = Stopwatch()..start();

    for (var i = 0; i < 6; i++) {
      final randomDouble = randomGenerator.nextDouble().toStringAsFixed(16);
      var requestStopwatch = Stopwatch()..start();
      dio.post(
        '$serverUrl/upload?n=$randomDouble',
        options: Options(
          headers: {
            Headers.contentTypeHeader: 'application/octet-stream',
            Headers.contentLengthHeader: data.length,
          },
          requestEncoder: (request, options) {
            return data;
          },
        ),
        data: Stream.fromIterable(data.map((e) => [e])),
        cancelToken: cancelToken,
        onSendProgress: (actualBytes, totalBytes) async {
          //Se convierten bytes a bits, luego a megabits y luego a Mbps
          uploadSpeedsList[i] = ((actualBytes * 8) / 1000000) /
              (requestStopwatch.elapsed.inMilliseconds / 1000);
        },
      ).then<Response<dynamic>?>((_) {
        requestIsFinished[i] = true;
        requestStopwatch.stop();
        return null;
      }).catchError((err) async {
        requestStopwatch.stop();
        if (CancelToken.isCancel(err)) {
          print('Request canceled: ${err.message}');
        } else {
          print(err);
        }
        return null;
      });
      await Future.delayed(const Duration(milliseconds: 10));
    }

    while (
        totalStopwatch.elapsed.inSeconds < 15 && allRequestsFinished == false) {
      allRequestsFinished =
          requestIsFinished.every((element) => element == true);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    totalStopwatch.stop();
    cancelToken.cancel('Cancelled');
    uploadTimer?.cancel();

    uploadRate = getAverageSpeed(uploadSpeedsList);
    setInputsUpload(uploadRate, true);

    setInputLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    loadingUpload = false;

    notifyListeners();
  }

  void setInputsDownload(double speedValue, bool exitValue) {
    if (artboardRive != null) {
      speed!.change(speedValue.toDouble());
      exitDownload!.change(exitValue);
      notifyListeners();
    }
  }

  void setInputsUpload(double speedValue, bool exitValue) {
    if (artboardRive != null) {
      speed!.change(speedValue.toDouble());
      exitUpload!.change(exitValue);
      notifyListeners();
    }
  }

  void setInputLoading(bool exit) {
    if (artboardLoadingRive != null) {
      exitLoading!.change(exit);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    downloadTimer?.cancel();
    super.dispose();
  }
}
