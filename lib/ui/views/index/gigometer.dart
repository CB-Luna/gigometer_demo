// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:speed_test/ui/widgets/primary_button.dart';
import 'package:speed_test/ui/widgets/rate_indicator.dart';
import 'package:speed_test_dart/classes/classes.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

import '../../../services/resolution.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class Gigometer extends StatefulWidget {
  const Gigometer({super.key});

  @override
  State<Gigometer> createState() => _GigometerState();
}

class _GigometerState extends State<Gigometer> {
  SpeedTestDart tester = SpeedTestDart();
  List<Server> bestServersList = [];
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

    for (var i = 0; i < 3; i++) {
      downloadRate = await tester.testDownloadSpeed(
          servers: bestServersList, simultaneousDownloads: 1);

      promedio = promedio + downloadRate;

      await Future.delayed(const Duration(milliseconds: 100));
      setInputsDownload(downloadRate, false);
    }

    setInputsDownload(downloadRate, true);

    setState(() {
      downloadRate = promedio / 3;
    });

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

    for (var i = 0; i < 5; i++) {
      uploadRate = await tester.testUploadSpeed(
          servers: bestServersList, simultaneousUploads: 5);

      promedio = promedio + uploadRate;

      await Future.delayed(const Duration(milliseconds: 100));
      setInputsUpload(uploadRate, false);
    }

    setInputsUpload(uploadRate, true);

    setInputLoading(true);

    setState(() {
      uploadRate = promedio / 5;
      loadingUpload = false;
    });
  }

/* -------------------------------------------------------------------------------- */

  Future<void> _testDownloadSpeed2() async {
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
        downloadRate = (_totalSize * 8 / 1024) /
            (stopwatch.elapsedMilliseconds / 1000) /
            1000;
      });
      setInputsDownload(downloadRate, false);

      promedio = promedio + downloadRate;
    }

    setInputsDownload(downloadRate, true);
    setState(() {
      downloadRate = promedio / 10;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loadingDownload = false;
      downloadDone = true;
    });

    _testUploadSpeed2();
  }

  Future<void> _testUploadSpeed2() async {
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
        uploadRate = (_totalSize * 8 / 1024) /
            (stopwatch.elapsedMilliseconds / 1000) /
            1000;
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
        speed!.change(speedValue.toDouble());
        exitDownload!.change(exitValue);
      });
    }
  }

  Future<void> setInputsUpload(double speedValue, bool exitValue) async {
    if (artboardRive != null) {
      setState(() {
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
      /* _testDownloadSpeed();
      _testUploadSpeed(); */
    });
    super.initState();

    rootBundle.load('assets/RiveAssets/GigOmeter.riv').then((data) async {
      final file = RiveFile.import(data);

      final _artboard = file.mainArtboard;

      stateMachineController =
          StateMachineController.fromArtboard(_artboard, 'State Machine 1');

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

      stateMachineLoadingController =
          StateMachineController.fromArtboard(_artboard, 'State Machine 1');

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
                  bgColor: Colors.blue),
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
                                await _testDownloadSpeed();
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

                                await _testDownloadSpeed();
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
