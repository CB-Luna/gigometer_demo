import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:speed_test/services/graphql_config.dart';
import 'package:speed_test/ui/views/index/index_view.dart';

void main() {
  runApp(
    GraphQLProvider(
      client: GraphQLConfiguration.clientToQuery(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          scrollbarTheme: const ScrollbarThemeData().copyWith(
        thumbColor: MaterialStateProperty.all(Colors.white.withOpacity(0.3)),
      )),
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                Color.fromARGB(255, 24, 74, 150),
                Color.fromARGB(255, 21, 65, 136),
              ],
              center: Alignment.bottomCenter,
              tileMode: TileMode.repeated,
              radius: 0.25,
            ),
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: const Center(
                child: IndexView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
