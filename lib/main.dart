// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';
import 'package:speed_test_dart/classes/classes.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    /* 
    var timer = await InstantTimer.periodic(
      duration: const Duration(seconds: 1),
      callback: (timer) async {
        downloadRate = await tester.testDownloadSpeed(
          servers: bestServersList,
          simultaneousDownloads: 1,
        );
        iteration++;
        promedio = promedio + downloadRate;
        setInputsDownload(0, true);
        // await Future.delayed(const Duration(milliseconds: 100));
        setInputsDownload(downloadRate, false);

        if (iteration == 3) {
          setInputsDownload(downloadRate, true);
          setState(() {
            downloadRate = promedio / 2;
          });
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            loadingDownload = false;
            donwloadDone = true;
          });

          _testUploadSpeed();
        }
      },
    );
     */
    setState(() {
      donwloadDone = false;
      loadingDownload = true;
    });

    double promedio = 0;

    for (var i = 0; i < 3; i++) {
      downloadRate = await tester.testDownloadSpeed(servers: bestServersList, simultaneousDownloads: 1);

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
      uploadRate = await tester.testUploadSpeed(servers: bestServersList, simultaneousUploads: 5);

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

    /* setInputsUpload(uploadRate, false);
    setState(() {
      loadingUpload = true;
    });
    final _uploadRate = await tester.testUploadSpeed(servers: bestServersList);
    setInputsUpload(_uploadRate, true);
    setState(() {
      uploadRate = _uploadRate;
      loadingUpload = false;
    }); */
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

    rootBundle.load('assets/RiveAssets/GigOmeter.riv').then((data) async {
      final fileDownload = RiveFile.import(data);
      final fileUpload = RiveFile.import(data);

      final _artboardDownload = fileDownload.mainArtboard;
      final _artboardUpload = fileUpload.mainArtboard;

      stateMachineControllerDownload = StateMachineController.fromArtboard(_artboardDownload, 'State Machine 1');
      stateMachineControllerUpload = StateMachineController.fromArtboard(_artboardUpload, 'State Machine 1');

      if (stateMachineControllerDownload != null && stateMachineControllerUpload != null) {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Speed Test Example App'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (donwloadDone == false)
                  Column(
                    children: [
                      const Text(
                        'Download Test:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      /* SizedBox(
                        height: 500,
                        width: 500,
                        child: Lottie.asset(
                          "assets/LottieAssets/CircleCount.json",
                        ),
                      ), */
                      SizedBox(
                        height: 500,
                        width: 500,
                        child: artboardDownload == null
                            ? const CircularProgressIndicator()
                            : Rive(
                                artboard: artboardDownload!,
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AnimatedDigitWidget(
                        value: downloadRate,
                        fractionDigits: 2,
                        prefix: "Download rate ",
                        suffix: "Mb/s",
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: readyToTest && !loadingDownload ? Colors.blue : Colors.grey,
                        ),
                        onPressed: loadingDownload
                            ? null
                            : () async {
                                if (!readyToTest || bestServersList.isEmpty) return;
                                await _testDownloadSpeed();
                              },
                        child: const Text('Start'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: readyToTest && !loadingDownload ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () => setInputsDownload(0, true),
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                if (donwloadDone == true)
                  Column(
                    children: [
                      const Text(
                        'Upload Test:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 500,
                        width: 500,
                        child: artboardUpload == null
                            ? const CircularProgressIndicator()
                            : Rive(
                                artboard: artboardUpload!,
                              ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedDigitWidget(
                        value: uploadRate,
                        fractionDigits: 2,
                        prefix: "Upload rate ",
                        suffix: "Mb/s",
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: readyToTest ? Colors.blue : Colors.grey,
                        ),
                        onPressed: loadingUpload
                            ? null
                            : () async {
                                if (!readyToTest || bestServersList.isEmpty) return;
                                await setInputsDownload(0, false);
                                await setInputsUpload(0, false);

                                downloadRate = 0;
                                uploadRate = 0;

                                await setInputsDownload(0, true);
                                await setInputsUpload(0, true);

                                await _testDownloadSpeed();
                              },
                        child: const Text('Retry'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: readyToTest && !loadingDownload ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () => setInputsUpload(0, true),
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
