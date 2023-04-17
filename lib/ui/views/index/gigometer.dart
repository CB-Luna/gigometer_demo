// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:rive/rive.dart';
import 'package:speed_test/global.dart';
import 'package:speed_test/services/resolution.dart';
import 'package:speed_test/ui/widgets/primary_button.dart';
import 'package:speed_test/ui/widgets/rate_indicator.dart';
import 'package:speed_test_dart/classes/classes.dart';
import 'package:speed_test_dart/enums/file_size.dart';

import '../../../modified_speed_test_dart.dart';

import 'package:http/http.dart' as http;

class Gigometer extends StatefulWidget {
  const Gigometer({super.key});

  @override
  State<Gigometer> createState() => _GigometerState();
}

class _GigometerState extends State<Gigometer> {
  SpeedTestDart tester = SpeedTestDart();
  List<Server> bestServersList = [];
  //List<FileSize> fileSize = [FileSize.SIZE_5000];
  bool encendido = false;

  double downloadRate = 0;
  double uploadRate = 0;

  bool readyToTest = false;
  bool loadingDownload = false;
  bool loadingUpload = false;

  Future<void> setBestServers() async {
    final settings = await tester.getSettings();
    final servers = settings.servers;

    final _bestServersList = await tester.getBestServers(
      servers: servers,
    );

    setState(() {
      bestServersList = _bestServersList;
      readyToTest = true;
    });
  }

  Future<void> _testDownloadSpeed() async {
    setState(() {
      downloadDone = false;
      loadingDownload = true;
    });
    setInputsDownload(0, false);
    setInputLoading(false);

    double promedio = 0;

    for (var i = 0; i < 10; i++) {
      downloadRate = await tester.testDownloadSpeed(
        servers: bestServersList,
        simultaneousDownloads: 10,
        //downloadSizes: fileSize,
      );

      promedio = promedio + downloadRate;

      //await Future.delayed(const Duration(milliseconds: 100));
      setInputsDownload(downloadRate, false);
    }

    setState(() {
      downloadRate = promedio / 10;
    });

    setInputsDownload(downloadRate, false);
    setInputsDownload(downloadRate, true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loadingDownload = false;
      downloadDone = true;
    });

    _testUploadSpeed();
  }

  Future<void> _testUploadSpeed() async {
    setState(() {
      loadingUpload = true;
    });

    double promedio = 0;

    for (var i = 0; i < 20; i++) {
      uploadRate = await tester.testUploadSpeed(
        servers: bestServersList,
        simultaneousUploads: 10,
      );

      promedio = promedio + uploadRate;

      await Future.delayed(const Duration(milliseconds: 100));
      setInputsUpload(uploadRate, false);
    }

    setState(() {
      uploadRate = promedio / 20;
    });

    setInputsUpload(uploadRate, false);
    setInputsUpload(uploadRate, true);

    setInputLoading(true);

    setState(() {
      loadingUpload = false;
    });
  }

  Future<void> _testDownloadSpeed4() async {
    setState(() {
      downloadDone = false;
      loadingDownload = true;
    });
    double promedio = 0;

    String url = 'http://dalspeedtest.rtatel.com:8080/speedtest';

    setInputLoading(false);

    var stopwatch = Stopwatch()..start();
    var response = await http.get(Uri.parse('$url/random6000x6000.jpg?r=0'));
    stopwatch.stop();
    var contentLength = int.parse(response.headers['content-length']!);
    var bytes = response.bodyBytes;
    var duration = stopwatch.elapsedMilliseconds;
    var speed = (bytes.length / 1024 / 1024) / (duration / 1000) * 10;
    print('Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('Tiempo de respuesta: ${duration / 1000} seg');
    print('Velocidad de descarga: ${speed.toStringAsFixed(2)} MB/s');

    setInputsDownload(speed, false);

    promedio = promedio + speed;

    stopwatch = Stopwatch()..start();
    response = await http.get(Uri.parse('$url/random5000x5000.jpg?r=0'));
    stopwatch.stop();
    contentLength = int.parse(response.headers['content-length']!);
    bytes = response.bodyBytes;
    duration = stopwatch.elapsedMilliseconds;
    speed = (bytes.length / 1024 / 1024) / (duration / 1000) * 10;
    print('Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('Tiempo de respuesta: ${duration / 1000} seg');
    print('Velocidad de descarga: ${speed.toStringAsFixed(2)} MB/s');

    setInputsDownload(speed, false);

    promedio = promedio + speed;

    stopwatch = Stopwatch()..start();
    response = await http.get(Uri.parse('$url/random3000x3000.jpg?r=0'));
    stopwatch.stop();
    contentLength = int.parse(response.headers['content-length']!);
    bytes = response.bodyBytes;
    duration = stopwatch.elapsedMilliseconds;
    speed = (bytes.length / 1024 / 1024) / (duration / 1000) * 8;
    print('Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('Tiempo de respuesta: ${duration / 1000} seg');
    print('Velocidad de descarga: ${speed.toStringAsFixed(2)} MB/s');

    setInputsDownload(speed, false);

    promedio = promedio + speed;

    stopwatch = Stopwatch()..start();
    response = await http.get(Uri.parse('$url/random2000x2000.jpg?r=0'));
    stopwatch.stop();
    contentLength = int.parse(response.headers['content-length']!);
    bytes = response.bodyBytes;
    duration = stopwatch.elapsedMilliseconds;
    speed = (bytes.length / 1024 / 1024) / (duration / 1000) * 10;
    print('Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('Tiempo de respuesta: ${duration / 1000} seg');
    print('Velocidad de descarga: ${speed.toStringAsFixed(2)} MB/s');

    setInputsDownload(speed, false);

    promedio = promedio + speed;

    stopwatch = Stopwatch()..start();
    response = await http.get(Uri.parse('$url/random1000x1000.jpg?r=0'));
    stopwatch.stop();
    contentLength = int.parse(response.headers['content-length']!);
    bytes = response.bodyBytes;
    duration = stopwatch.elapsedMilliseconds;
    speed = (bytes.length / 1024 / 1024) / (duration / 1000) * 10;
    print('Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('Tiempo de respuesta: ${duration / 1000} seg');
    print('Velocidad de descarga: ${speed.toStringAsFixed(2)} MB/s');

    setInputsDownload(speed, false);

    promedio = promedio + speed;

    promedio = promedio / 5;

    print('El promedio fué de: ${promedio}');

    setInputsDownload(promedio, false);
    setInputsDownload(promedio, true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loadingDownload = false;
      downloadDone = true;
    });

    await _testUploadSpeed4();
  }

  Future<void> _testUploadSpeed4() async {
    setState(() {
      loadingUpload = true;
    });

    double promedio = 0;

    String url = 'https://rtatel.cbluna-dev.com/daliapp/speedtest/upload/v2';

    var fileBytes = await rootBundle.load('assets/RiveAssets/GigOmeter.riv');
    final byteBuffer = fileBytes.buffer;
    final uint8ListFile = Uint8List.view(byteBuffer);

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes('file', uint8ListFile));
    request.headers.addAll({});

    // LLamado 1
    var stopwatch = Stopwatch()..start();
    await request.send();
    stopwatch.stop();
    var contentLength = request.contentLength;
    var duration = stopwatch.elapsedMilliseconds;
    var speed = (contentLength / 1024 / 1024) / (duration / 1000) * 10;
    print('----Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('----Tiempo de carga: ${duration / 1000} seg');
    print('----Velocidad de carga: ${speed.toStringAsFixed(2)} MB/s');

    await Future.delayed(const Duration(milliseconds: 1000));
    setInputsUpload(speed, false);

    promedio = promedio + speed;

    // LLamado 2
    var request2 = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes('file', uint8ListFile));
    request.headers.addAll({});
    stopwatch = Stopwatch()..start();
    await request2.send();
    stopwatch.stop();
    duration = stopwatch.elapsedMilliseconds;
    speed = (contentLength / 1024 / 1024) / (duration / 1000) * 10;
    print('----Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('----Tiempo de carga: ${duration / 1000} seg');
    print('----Velocidad de carga: ${speed.toStringAsFixed(2)} MB/s');

    await Future.delayed(const Duration(milliseconds: 1000));
    setInputsUpload(speed, false);

    promedio = promedio + speed;

    // LLamado 3
    var request3 = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes('file', uint8ListFile));
    request.headers.addAll({});
    stopwatch = Stopwatch()..start();
    await request3.send();
    stopwatch.stop();
    duration = stopwatch.elapsedMilliseconds;
    speed = (contentLength / 1024 / 1024) / (duration / 1000) * 10;
    print('----Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('----Tiempo de carga: ${duration / 1000} seg');
    print('----Velocidad de carga: ${speed.toStringAsFixed(2)} MB/s');

    await Future.delayed(const Duration(milliseconds: 1000));
    setInputsUpload(speed, false);

    promedio = promedio + speed;

    // LLamado 4
    var request4 = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes('file', uint8ListFile));
    request.headers.addAll({});
    stopwatch = Stopwatch()..start();
    await request4.send();
    stopwatch.stop();
    duration = stopwatch.elapsedMilliseconds;
    speed = (contentLength / 1024 / 1024) / (duration / 1000) * 10;
    print('----Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('----Tiempo de carga: ${duration / 1000} seg');
    print('----Velocidad de carga: ${speed.toStringAsFixed(2)} MB/s');

    await Future.delayed(const Duration(milliseconds: 1000));
    setInputsUpload(speed, false);

    promedio = promedio + speed;

    // LLamado 5
    var request5 = http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes('file', uint8ListFile));
    request.headers.addAll({});
    stopwatch = Stopwatch()..start();
    await request5.send();
    stopwatch.stop();
    duration = stopwatch.elapsedMilliseconds;
    speed = (contentLength / 1024 / 1024) / (duration / 1000) * 10;
    print('----Tamaño del archivo: ${(contentLength / 1024 / 1024).toStringAsFixed(2)} MB');
    print('----Tiempo de carga: ${duration / 1000} seg');
    print('----Velocidad de carga: ${speed.toStringAsFixed(2)} MB/s');

    await Future.delayed(const Duration(milliseconds: 1000));
    setInputsUpload(speed, false);

    promedio = promedio + speed;

    promedio = promedio / 5;
    await Future.delayed(const Duration(milliseconds: 1000));
    setInputsUpload(promedio, false);
    setInputsUpload(promedio, true);
    setInputLoading(true);

    setState(() {
      loadingUpload = false;
    });
  }

  Future<void> _testSpeed() async {
    browser = await puppeteer.connect(
      browserUrl: 'https://rtatel.cbluna-dev.com/',
      slowMo: Duration(seconds: 5),
    );

    final page = await browser.newPage();

    await page.goto('http://localhost:8080/Speed-Test/index.html');

    final starButton = await page.$('.startButton');

    await starButton.click();

    await Future.delayed(Duration(seconds: 5));

    await browser.close();
  }

/* -------------------------------------------------------------------------------- */

  Uri createTestUrl(Server server, String file) {
    return Uri.parse(
      Uri.parse(server.url).toString().replaceAll('upload.php', file),
    );
  }

  List<String> generateDownloadUrls(
    Server server,
    int retryCount,
    List<FileSize> downloadSizes,
  ) {
    final downloadUriBase = createTestUrl(server, 'random{0}x{0}.jpg?r={1}');
    final result = <String>[];
    for (final ds in downloadSizes) {
      for (var i = 0; i < retryCount; i++) {
        result.add(
          downloadUriBase.toString().replaceAll('%7B0%7D', FILE_SIZE_MAPPING[ds].toString()).replaceAll('%7B1%7D', i.toString()),
        );
      }
    }
    return result;
  }

/*  Future<void> _testDownloadSpeed3() async {
    setState(() {
      downloadDone = false;
      loadingDownload = true;
    });
    setInputsDownload(0, false);
    setInputLoading(false);

    double promedio = 0;

    try {
      for (var i = 0; i < 2; i++) {
        final testData = generateDownloadUrls(bestServersList[0], 1, defaultDownloadSizes);
        final stopwatches = <Stopwatch>[
          Stopwatch(),
          Stopwatch(),
          Stopwatch(),
          Stopwatch(),
          Stopwatch(),
          Stopwatch(),
        ];

        stopwatches[0].start();
        stopwatches[1].start();
        stopwatches[2].start();
        stopwatches[3].start();
        stopwatches[4].start();
        stopwatches[5].start();

        await Future.wait([
          http.get(Uri.parse(testData[0])).then((value) {
            stopwatches[0].stop();
            print(stopwatches[0].elapsedMilliseconds);
            downloadRate = (value.bodyBytes.length * 8 / 1024) / (stopwatches[0].elapsedMilliseconds / 1000) / 1000;
            promedio = promedio + downloadRate;
            setInputsDownload(downloadRate, false);
          }),
          http.get(Uri.parse(testData[1])).then((value) {
            stopwatches[1].stop();
            print(stopwatches[1].elapsedMilliseconds);
            downloadRate = (value.bodyBytes.length * 8 / 1024) / (stopwatches[1].elapsedMilliseconds / 1000) / 1000;
            promedio = promedio + downloadRate;
            setInputsDownload(downloadRate, false);
          }),
          http.get(Uri.parse(testData[2])).then((value) {
            stopwatches[2].stop();
            print(stopwatches[2].elapsedMilliseconds);
            downloadRate = (value.bodyBytes.length * 8 / 1024) / (stopwatches[2].elapsedMilliseconds / 1000) / 1000;
            promedio = promedio + downloadRate;
            setInputsDownload(downloadRate, false);
          }),
          http.get(Uri.parse(testData[3])).then((value) {
            stopwatches[3].stop();
            print(stopwatches[3].elapsedMilliseconds);
            downloadRate = (value.bodyBytes.length * 8 / 1024) / (stopwatches[3].elapsedMilliseconds / 1000) / 1000;
            promedio = promedio + downloadRate;
            setInputsDownload(downloadRate, false);
          }),
          http.get(Uri.parse(testData[4])).then((value) {
            stopwatches[4].stop();
            print(stopwatches[4].elapsedMilliseconds);
            downloadRate = (value.bodyBytes.length * 8 / 1024) / (stopwatches[4].elapsedMilliseconds / 1000) / 1000;
            promedio = promedio + downloadRate;
            setInputsDownload(downloadRate, false);
          }),
          http.get(Uri.parse(testData[5])).then((value) {
            stopwatches[5].stop();
            print(stopwatches[5].elapsedMilliseconds);
            downloadRate = (value.bodyBytes.length * 8 / 1024) / (stopwatches[5].elapsedMilliseconds / 1000) / 1000;
            promedio = promedio + downloadRate;
            setInputsDownload(downloadRate, false);
          }),
        ]);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    setState(() {
      downloadRate = promedio / 12;
    });

    setInputsDownload(downloadRate, false);
    setInputsDownload(downloadRate, true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loadingDownload = false;
      downloadDone = true;
    });

    _testUploadSpeed();
  }
 */
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
/* -------------------------------------------------------------------------------- */

  Artboard? artboardRive;
  StateMachineController? stateMachineController;
  SMIInput<bool>? exitDownload;
  SMIInput<bool>? exitUpload;
  SMIInput<double>? speed;
  bool downloadDone = false;

  Artboard? artboardLoadingRive;
  StateMachineController? stateMachineLoadingController;
  SMIInput<bool>? exitLoading;

  Future<void> setInputsDownload(double speedValue, bool exitValue) async {
    if (artboardRive != null) {
      setState(() {
        downloadRate = speedValue.toDouble();
        speed!.change(speedValue.toDouble());
        exitDownload!.change(exitValue);
      });
    }
  }

  Future<void> setInputsUpload(double speedValue, bool exitValue) async {
    if (artboardRive != null) {
      setState(() {
        uploadRate = speedValue.toDouble();
        speed!.change(speedValue.toDouble());
        exitUpload!.change(exitValue);
      });
    }
  }

  Future<void> setInputLoading(bool exit) async {
    if (artboardLoadingRive != null) {
      setState(() {
        exitLoading!.change(exit);
      });
    }
  }

/* -------------------------------------------------------------------------------- */

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBestServers();
    });
    super.initState();

    rootBundle.load('assets/RiveAssets/GigOmeter.riv').then((data) async {
      final file = RiveFile.import(data);

      final _artboard = file.mainArtboard;

      stateMachineController = StateMachineController.fromArtboard(_artboard, 'State Machine 1');

      if (stateMachineController != null) {
        _artboard.addController(stateMachineController!);

        speed = stateMachineController!.findInput('speed');
        exitDownload = stateMachineController!.findInput('exitDownload');
        exitUpload = stateMachineController!.findInput('exitUpload');

        speed!.change(0);
        exitDownload!.change(true);
        exitUpload!.change(true);

        setInputsUpload(uploadRate, true);
      }

      setState(
        () {
          artboardRive = _artboard;
        },
      );
    });

    rootBundle.load('assets/RiveAssets/LoadingCar.riv').then((data) async {
      final file = RiveFile.import(data);

      final _artboard = file.mainArtboard;

      stateMachineLoadingController = StateMachineController.fromArtboard(_artboard, 'State Machine 1');

      if (stateMachineLoadingController != null) {
        _artboard.addController(stateMachineLoadingController!);

        exitLoading = stateMachineLoadingController!.findInput('exit');

        exitLoading!.change(true);
      }

      setState(
        () {
          artboardLoadingRive = _artboard;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          children: [
            FractionallySizedBox(
              widthFactor: 0.325,
              child: RateIndicator(
                isActive: loadingDownload,
                isDone: downloadDone,
                isDownload: true,
                rateValue: downloadRate,
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.325,
              child: RateIndicator(
                isActive: loadingUpload,
                isDone: (downloadDone && readyToTest && !loadingUpload),
                isDownload: false,
                rateValue: uploadRate,
                bgColor: Colors.blue,
              ),
            ),
          ],
        ),
        Column(
          children: [
            FittedBox(
              child: SizedBox(
                height: screenSize(context).height * 0.55,
                width: screenSize(context).height * 0.55,
                child: artboardRive == null
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          Rive(artboard: artboardRive!),
                          Rive(artboard: artboardLoadingRive!),
                        ],
                      ),
              ),
            ),
            Wrap(
              children: [
                !downloadDone
                    ? PrimaryButton(
                        text: 'Start',
                        isActive: readyToTest && !loadingDownload,
                        bgColor: const Color(0xFF25CB8E),
                        onPressed: loadingDownload
                            ? null
                            : () async {
                                if (!readyToTest || bestServersList.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  speed!.change(0);
                                  exitDownload!.change(false);
                                  exitUpload!.change(false);
                                });
                                await _testSpeed();
                              },
                      )
                    : PrimaryButton(
                        isActive: readyToTest,
                        bgColor: Colors.blue,
                        onPressed: loadingUpload
                            ? null
                            : () async {
                                if (!readyToTest || bestServersList.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  downloadDone = false;
                                  downloadRate = 0;
                                  uploadRate = 0;
                                  speed!.change(0);
                                  exitDownload!.change(false);
                                  exitUpload!.change(false);
                                });

                                await _testSpeed();
                              },
                        text: 'Retry',
                      ),
                PrimaryButton(
                  text: 'Stop',
                  isActive: readyToTest && !loadingDownload,
                  onPressed: () => setInputsDownload(0, true),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
