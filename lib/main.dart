import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:seo/seo.dart';

import 'package:speed_test/services/graphql_config.dart';
import 'package:speed_test/ui/views/index/index_view.dart';

import 'ui/widgets/seo_widgets/head_widget.dart';

void main() {
  runApp(
    GraphQLProvider(
      client: GraphQLConfiguration.clientToQuery(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return SeoController(
      tree: WidgetTree(context: context),
      child: AppHead(
        title: "Internet Speed Test | RTA Gigometer | Test your speed",
        description:
            "Wondering how fast your internet really is? Test your speed! RTA's Gigometer provides quick and accurate readings of your connection speed.",
        child: MaterialApp(
          title: "Internet Speed Test | RTA Gigometer | Test your speed",
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
              scrollbarTheme: const ScrollbarThemeData().copyWith(
            thumbColor:
                MaterialStateProperty.all(Colors.white.withOpacity(0.3)),
          )),
          home: Scaffold(
            body: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.bottomCenter,
                      fit: BoxFit.cover,
                      image: AssetImage('/images/ondas.jpg'))),
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
        ),
      ),
    );
  }
}
