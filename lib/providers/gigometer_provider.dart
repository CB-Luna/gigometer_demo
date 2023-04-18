import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:speed_test/modified_speed_test_dart.dart';
import 'package:speed_test_dart/classes/server.dart';
import 'package:speed_test_dart/enums/file_size.dart';

class GigometerProvider extends ChangeNotifier {
  SpeedTestDart tester = SpeedTestDart();
  List<Server> bestServersList = [];
  List<FileSize> fileSize = [FileSize.SIZE_3000];
  bool encendido = false;

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

  Future<void> setBestServers() async {
    final settings = await tester.getSettings();
    final servers = settings.servers;

    bestServersList = await tester.getBestServers(servers: servers);

    readyToTest = true;

    notifyListeners();
  }

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

      await setInputsUpload(uploadRate, true);
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
    notifyListeners();
  }

  Future<void> testDownloadSpeed() async {
    downloadDone = false;
    loadingDownload = true;
    await setInputsDownload(0, false);
    await setInputLoading(false);

    double promedio = 0;

    for (var i = 0; i < 20; i++) {
      downloadRate = await tester.testDownloadSpeed(
        servers: bestServersList,
        downloadSizes: fileSize,
      );

      promedio = promedio + downloadRate;

      await Future.delayed(const Duration(milliseconds: 100));
      await setInputsDownload(downloadRate, false);
    }

    downloadRate = promedio / 20;

    await setInputsDownload(downloadRate, false);
    await setInputsDownload(downloadRate, true);

    await Future.delayed(const Duration(seconds: 2));

    loadingDownload = false;
    downloadDone = true;

    notifyListeners();

    await testUploadSpeed();
  }

  Future<void> testUploadSpeed() async {
    loadingUpload = true;

    double promedio = 0;

    for (var i = 0; i < 20; i++) {
      uploadRate = await tester.testUploadSpeed(servers: bestServersList);

      promedio = promedio + uploadRate;

      await Future.delayed(const Duration(milliseconds: 100));
      await setInputsUpload(uploadRate, false);
    }

    uploadRate = promedio / 20;

    await setInputsUpload(uploadRate, false);
    await setInputsUpload(uploadRate, true);

    await setInputLoading(true);

    loadingUpload = false;

    notifyListeners();
  }

/*   Future<void> _testDownloadSpeed2() async {
    setState(() {
      downloadDone = false;
      loadingDownload = true;
    });

    double promedio = 0;

    final stopwatch = Stopwatch()..start();
    final tasks = <int>[];

    for (var i = 0; i < 10; i++) {
      double rndm = Random().nextDouble() * 1.1000000000000000;
      var response = await http.get(
        Uri.parse(
          'https://rtatel.cbluna-dev.com/downloading?n=$rndm',
        ),
      );
      tasks.add(response.bodyBytes.length);
      final _totalSize = tasks.reduce((a, b) => a + b);

      setState(() {
        downloadRate = (_totalSize * 8 / 1024) / (stopwatch.elapsedMilliseconds / 1000) / 1000;
      });
      setInputsDownload(downloadRate, false);

      promedio = promedio + downloadRate;
    }

    setState(() {
      uploadRate = promedio / 20;
    });

    setInputsUpload(uploadRate, false);
    setInputsUpload(uploadRate, true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loadingDownload = false;
      downloadDone = true;
    });

    _testUploadSpeed2();
  }
 */
/*   Future<void> _testUploadSpeed2() async {
    setState(() {
      loadingUpload = true;
    });

    double promedio = 0;

    final stopwatch = Stopwatch()..start();
    final tasks = <int>[];

    for (var i = 0; i < 10; i++) {
      double rndm = Random().nextDouble() * 1.1000000000000000;
      var response = await http.post(
        Uri.parse(
          'https://rtatel.cbluna-dev.com/upload?n=$rndm',
        ),
      );

      tasks.add(response.bodyBytes.length);
      final _totalSize = tasks.reduce((a, b) => a + b);
      setState(() {
        uploadRate = (_totalSize * 8 / 1024) / (stopwatch.elapsedMilliseconds / 1000) / 1000;
      });

      promedio = promedio + uploadRate;

      setInputsUpload(uploadRate, false);
    }

    setInputsUpload(uploadRate, true);

    setInputLoading(true);

    setState(() {
      uploadRate = promedio / 10;
      loadingUpload = false;
    });
  }
 */

  Future<void> setInputsDownload(double speedValue, bool exitValue) async {
    if (artboardRive != null) {
      speed!.change(speedValue.toDouble());
      exitDownload!.change(exitValue);
      notifyListeners();
    }
  }

  Future<void> setInputsUpload(double speedValue, bool exitValue) async {
    if (artboardRive != null) {
      speed!.change(speedValue.toDouble());
      exitUpload!.change(exitValue);
      notifyListeners();
    }
  }

  Future<void> setInputLoading(bool exit) async {
    if (artboardLoadingRive != null) {
      exitLoading!.change(exit);
      notifyListeners();
    }
  }
}
