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
      donwloadDone = false;
      loadingDownload = true;
    });

    double promedio = 0;

    for (var i = 0; i < 3; i++) {
      downloadRate = await tester.testDownloadSpeed(
          servers: bestServersList, simultaneousDownloads: 1);

      promedio = promedio + downloadRate;

      setInputsDownload(0, true);
      await Future.delayed(const Duration(milliseconds: 100));
      setInputsDownload(downloadRate, false);
    }

    setInputsDownload(downloadRate, true);
    setState(() {
      downloadRate = promedio / 2;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      loadingDownload = false;
      donwloadDone = true;
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

      setInputsUpload(0, true);
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

  Artboard? artboardDownload;
  StateMachineController? stateMachineControllerDownload;
  SMIInput<bool>? exitDownload;
  SMIInput<double>? speedDownload;
  bool donwloadDone = false;

  Artboard? artboardUpload;
  StateMachineController? stateMachineControllerUpload;
  SMIInput<bool>? exitUpload;
  SMIInput<double>? speedUpload;

  Future<void> setInputsDownload(double speedValue, bool exitValue) async {
    if (artboardDownload != null) {
      setState(() {
        speedDownload!.change(speedValue.toDouble());
        exitDownload!.change(exitValue);
      });
    }
  }

  Future<void> setInputsUpload(double speedValue, bool exitValue) async {
    if (artboardDownload != null) {
      setState(() {
        speedUpload!.change(speedValue.toDouble());
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

    rootBundle.load('assets/RiveAssets/GigTrans.riv').then((data) async {
      final fileDownload = RiveFile.import(data);
      final fileUpload = RiveFile.import(data);

      final _artboardDownload = fileDownload.mainArtboard;
      final _artboardUpload = fileUpload.mainArtboard;

      stateMachineControllerDownload = StateMachineController.fromArtboard(
          _artboardDownload, 'State Machine 1');
      stateMachineControllerUpload = StateMachineController.fromArtboard(
          _artboardUpload, 'State Machine 1');

      if (stateMachineControllerDownload != null &&
          stateMachineControllerUpload != null) {
        _artboardDownload.addController(stateMachineControllerDownload!);
        _artboardUpload.addController(stateMachineControllerUpload!);

        exitDownload = stateMachineControllerDownload!.findInput('exit');
        speedDownload = stateMachineControllerDownload!.findInput('speed');
        speedDownload!.change(downloadRate.toDouble());
        exitDownload!.change(true);

        exitUpload = stateMachineControllerUpload!.findInput('exit');
        speedUpload = stateMachineControllerUpload!.findInput('speed');
        speedUpload!.change(uploadRate.toDouble());
        exitUpload!.change(true);

        setInputsUpload(uploadRate, true);
      }

      setState(
        () {
          artboardDownload = _artboardDownload;
          artboardUpload = _artboardUpload;
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
              isDone: donwloadDone,
              isDownload: true,
              rateValue: downloadRate,
            ),
            RateIndicator(
              isActive: loadingUpload,
              isDone: donwloadDone && readyToTest,
              isDownload: false,
              rateValue: uploadRate,
            ),
          ],
        ),
        !donwloadDone
            ? Column(
                children: [
                  SizedBox(
                    height: 450,
                    width: 450,
                    child: artboardDownload == null
                        ? const CircularProgressIndicator()
                        : Rive(
                            artboard: artboardDownload!,
                          ),
                  ),
                  Wrap(
                    children: [
                      PrimaryButton(
                        text: 'Start',
                        isActive: readyToTest && !loadingDownload,
                        bgColor: const Color(0xFF25CB8E),
                        onPressed: loadingDownload
                            ? null
                            : () async {
                                if (!readyToTest || bestServersList.isEmpty) {
                                  return;
                                }
                                await _testDownloadSpeed();
                              },
                      ),
                      PrimaryButton(
                        text: 'Stop',
                        isActive: readyToTest && !loadingDownload,
                        onPressed: () => setInputsDownload(0, true),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: 450,
                    width: 450,
                    child: artboardUpload == null
                        ? const CircularProgressIndicator()
                        : Rive(
                            artboard: artboardUpload!,
                          ),
                  ),
                  Wrap(
                    children: [
                      PrimaryButton(
                        isActive: readyToTest,
                        bgColor: Colors.blue,
                        onPressed: loadingUpload
                            ? null
                            : () async {
                                if (!readyToTest || bestServersList.isEmpty) {
                                  return;
                                }
                                await setInputsDownload(0, false);
                                await setInputsUpload(0, false);

                                downloadRate = 0;
                                uploadRate = 0;

                                await setInputsDownload(0, true);
                                await setInputsUpload(0, true);

                                await _testDownloadSpeed();
                              },
                        text: 'Retry',
                      ),
                      PrimaryButton(
                        isActive: readyToTest && !loadingDownload,
                        onPressed: () => setInputsUpload(0, true),
                        text: 'Stop',
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }
}
