import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'package:speed_test/providers/providers.dart';
import 'package:speed_test/services/resolution.dart';
import 'package:speed_test/ui/widgets/primary_button.dart';
import 'package:speed_test/ui/widgets/rate_indicator.dart';

class Gigometer extends StatefulWidget {
  const Gigometer({super.key});

  @override
  State<Gigometer> createState() => _GigometerState();
}

class _GigometerState extends State<Gigometer> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      GigometerProvider provider = Provider.of<GigometerProvider>(
        context,
        listen: false,
      );
      await provider.setBestServers();
      await provider.setRootBundle();
      /* _testDownloadSpeed();
      _testUploadSpeed(); */
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GigometerProvider provider = Provider.of<GigometerProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          children: [
            FractionallySizedBox(
              widthFactor: 0.325,
              child: RateIndicator(
                isActive: provider.loadingDownload,
                isDone: provider.downloadDone,
                isDownload: true,
                rateValue: provider.downloadRate,
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.325,
              child: RateIndicator(
                isActive: provider.loadingUpload,
                isDone: (provider.downloadDone &&
                    provider.readyToTest &&
                    !provider.loadingUpload),
                isDownload: false,
                rateValue: provider.uploadRate,
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
                child: provider.artboardRive == null
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          Rive(artboard: provider.artboardRive!),
                          Rive(artboard: provider.artboardLoadingRive!),
                        ],
                      ),
              ),
            ),
            Wrap(
              children: [
                !provider.downloadDone
                    ? PrimaryButton(
                        text: 'Start',
                        isActive:
                            provider.readyToTest && !provider.loadingDownload,
                        bgColor: const Color(0xFF25CB8E),
                        onPressed: provider.loadingDownload
                            ? null
                            : () async {
                                if (!provider.readyToTest ||
                                    provider.bestServersList.isEmpty) {
                                  return;
                                }

                                provider.speed!.change(0);
                                provider.exitDownload!.change(false);
                                provider.exitUpload!.change(false);

                                await provider.testDownloadSpeed();
                              },
                      )
                    : PrimaryButton(
                        isActive: provider.readyToTest,
                        bgColor: Colors.blue,
                        onPressed: provider.loadingUpload
                            ? null
                            : () async {
                                if (!provider.readyToTest ||
                                    provider.bestServersList.isEmpty) {
                                  return;
                                }

                                provider.downloadDone = false;
                                provider.downloadRate = 0;
                                provider.uploadRate = 0;
                                provider.speed!.change(0);
                                provider.exitDownload!.change(false);
                                provider.exitUpload!.change(false);

                                await provider.testDownloadSpeed();
                              },
                        text: 'Retry',
                      ),
                PrimaryButton(
                  text: 'Stop',
                  isActive: provider.readyToTest && !provider.loadingDownload,
                  onPressed: () async {
                    await provider.setInputsDownload(0, true);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
