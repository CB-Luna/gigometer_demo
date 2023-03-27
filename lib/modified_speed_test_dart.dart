library speed_test_dart;

import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:speed_test_dart/classes/classes.dart';
import 'package:speed_test_dart/constants.dart';
import 'package:speed_test_dart/enums/file_size.dart';
import 'package:sync/sync.dart';
import 'package:xml_parser/xml_parser.dart';

/// A Speed tester.
class SpeedTestDart {
  /// Returns [Settings] from speedtest.net.
  Future<Settings> getSettings() async {
    // final response = await http.get(Uri.parse(configUrl));
    final settings = Settings.fromXMLElement(
      XmlDocument.from('''
<?xml version="1.0" encoding="UTF-8"?>
<settings>
    <client ip="000.000.000.000" lat="0000.0000" lon="0000.0000" isp="SAFE" isprating="5" rating="0" ispdlavg="0" ispulavg="0" loggedin="0" country="UNK" />
    <server-config threadcount="4" ignoreids="" notonmap="" forcepingid="" preferredserverid=""/>
    <licensekey>f7a45ced624d3a70-1df5b7cd427370f7-b91ee21d6cb22d7b</licensekey>
    <customer>speedtest</customer>
    <odometer start="19601573884" rate="12"/>
    <times dl1="5000000" dl2="35000000" dl3="800000000" ul1="1000000" ul2="8000000" ul3="35000000"/>
    <download testlength="10" initialtest="250K" mintestsize="250K" threadsperurl="4"/>
    <upload testlength="10" ratio="5" initialtest="0" mintestsize="32K" threads="2" maxchunksize="512K" maxchunkcount="50" threadsperurl="4"/>
    <latency testlength="10" waittime="50" timeout="20"/>
    <socket-download testlength="15" initialthreads="4" minthreads="4" maxthreads="32" threadratio="750K" maxsamplesize="5000000" minsamplesize="32000" startsamplesize="1000000" startbuffersize="1" bufferlength="5000" packetlength="1000" readbuffer="65536"/>
    <socket-upload testlength="15" initialthreads="dyn:tcpulthreads" minthreads="dyn:tcpulthreads" maxthreads="32" threadratio="750K" maxsamplesize="1000000" minsamplesize="32000" startsamplesize="100000" startbuffersize="2" bufferlength="1000" packetlength="1000" disabled="false"/>
    <socket-latency testlength="10" waittime="50" timeout="20"/>
    <translation lang="xml"></translation>
</settings>
''')?.getElement('settings'),
    );

    var serversConfig = ServersList(<Server>[]);
    for (final element in serversUrls) {
      if (serversConfig.servers.isNotEmpty) break;
      try {
        // final resp = await http.get(Uri.parse(element));

        serversConfig = ServersList.fromXMLElement(
          XmlDocument.from('''
<?xml version="1.0" encoding="UTF-8"?>
<settings>
    <servers>
         <server url="http://dalspeedtest.rtatel.com:8080/speedtest/upload.php" lat="34.0500" lon="-118.2500" name="Fallas, TX" country="United States" cc="US" sponsor="Rural Telecommunications of America, Inc." id="18401"  host="dalspeedtest.rtatel.com:8080" />
    </servers>
</settings>
''')?.getElement('settings'),
        );
      } catch (ex) {
        serversConfig = ServersList(<Server>[]);
      }
    }

    final ignoredIds = settings.serverConfig.ignoreIds.split(',');
    serversConfig.calculateDistances(settings.client.geoCoordinate);
    settings.servers = serversConfig.servers
        .where(
          (s) => !ignoredIds.contains(s.id.toString()),
        )
        .toList();
    settings.servers.sort((a, b) => a.distance.compareTo(b.distance));

    return settings;
  }

  /// Returns a List[Server] with the best servers, ordered
  /// by lowest to highest latency.
  Future<List<Server>> getBestServers({
    required List<Server> servers,
    int retryCount = 2,
    int timeoutInSeconds = 2,
  }) async {
    List<Server> serversToTest = [];

    for (final server in servers) {
      final latencyUri = createTestUrl(server, 'latency.txt');
      final stopwatch = Stopwatch();

      stopwatch.start();
      try {
        /* await http.get(latencyUri).timeout(
              Duration(
                seconds: timeoutInSeconds,
              ),
              onTimeout: (() => http.Response(
                    '999999999',
                    500,
                  )), 
            ); */
        // If a server fails the request, continue in the iteration
      } catch (_) {
        continue;
      } finally {
        stopwatch.stop();
      }

      final latency = stopwatch.elapsedMilliseconds / retryCount;
      if (latency < 500) {
        server.latency = latency;
        serversToTest.add(server);
      }
    }

    serversToTest.sort((a, b) => a.latency.compareTo(b.latency));

    return serversToTest;
  }

  /// Creates [Uri] from [Server] and [String] file
  Uri createTestUrl(Server server, String file) {
    return Uri.parse(
      Uri.parse(server.url).toString().replaceAll('upload.php', file),
    );
  }

  /// Returns urls for download test.
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

  /// Returns [double] downloaded speed in MB/s.
  Future<double> testDownloadSpeed({
    required List<Server> servers,
    int simultaneousDownloads = 1,
    int retryCount = 1,
    List<FileSize> downloadSizes = defaultDownloadSizes,
  }) async {
    double downloadSpeed = 0;

    // Iterates over all servers, if one request fails, the next one is tried.
    for (final s in servers) {
      final testData = generateDownloadUrls(s, retryCount, downloadSizes);
      final semaphore = Semaphore(simultaneousDownloads);
      final tasks = <int>[];
      final stopwatch = Stopwatch()..start();

      try {
        await Future.forEach(testData, (String td) async {
          await semaphore.acquire();
          try {
            final data = await http.get(Uri.parse(td));
            tasks.add(data.bodyBytes.length);
          } finally {
            semaphore.release();
          }
        });
        stopwatch.stop();
        final _totalSize = tasks.reduce((a, b) => a + b);
        downloadSpeed = (_totalSize * 8 / 1024) / (stopwatch.elapsedMilliseconds / 1000) / 1000;
        break;
      } catch (_) {
        continue;
      }
    }
    return downloadSpeed;
  }

  /// Returns [double] upload speed in MB/s.
  Future<double> testUploadSpeed({
    required List<Server> servers,
    int simultaneousUploads = 2,
    int retryCount = 3,
  }) async {
    double uploadSpeed = 0;
    for (var s in servers) {
      final testData = generateUploadData(retryCount);
      final semaphore = Semaphore(simultaneousUploads);
      final stopwatch = Stopwatch()..start();
      final tasks = <int>[];

      try {
        await Future.forEach(testData, (String td) async {
          await semaphore.acquire();
          try {
            // do post request to measure time for upload
            await http.post(Uri.parse(s.url), body: td);
            tasks.add(td.length);
          } finally {
            semaphore.release();
          }
        });
        stopwatch.stop();
        final _totalSize = tasks.reduce((a, b) => a + b);
        uploadSpeed = (_totalSize * 8 / 1024) / (stopwatch.elapsedMilliseconds / 1000) / 1000;
        break;
      } catch (_) {
        continue;
      }
    }
    return uploadSpeed;
  }

  /// Generate list of [String] urls for upload.
  List<String> generateUploadData(int retryCount) {
    final random = Random();
    final result = <String>[];

    for (var sizeCounter = 1; sizeCounter < maxUploadSize + 1; sizeCounter++) {
      final size = sizeCounter * 200 * 1024;
      final builder = StringBuffer()..write('content ${sizeCounter.toString()}=');

      for (var i = 0; i < size; ++i) {
        builder.write(hars[random.nextInt(hars.length)]);
      }

      for (var i = 0; i < retryCount; i++) {
        result.add(builder.toString());
      }
    }

    return result;
  }
}
