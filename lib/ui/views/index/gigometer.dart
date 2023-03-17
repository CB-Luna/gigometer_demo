// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:speed_test/ui/widgets/primary_button.dart';
import 'package:speed_test/ui/widgets/rate_indicator.dart';
import 'package:speed_test_dart/classes/classes.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

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

    setState(() {
      uploadRate = promedio / 5;
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          children: [
            RateIndicator(
              isActive: loadingDownload,
              isDone: downloadDone,
              isDownload: true,
              rateValue: downloadRate,
            ),
            RateIndicator(
                isActive: loadingUpload,
                isDone: (downloadDone && readyToTest && !loadingUpload),
                isDownload: false,
                rateValue: uploadRate,
                bgColor: Colors.blue),
          ],
        ),
        Column(
          children: [
            SizedBox(
              height: 450,
              width: 450,
              child: artboardRive == null
                  ? const CircularProgressIndicator()
                  : Rive(
                      artboard: artboardRive!,
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
