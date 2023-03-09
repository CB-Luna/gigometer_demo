import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:speed_test/ui/views/index/index_view.dart';

import 'services/graphql_config.dart';

void main() => runApp(GraphQLProvider(
      client: GraphQLConfiguration.clientToQuery(),
      child: const MyApp(),
    ));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
/* -------------------------------------------------------------------------------- */

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFEDF6FF),
        body: SingleChildScrollView(
          child: Center(child: IndexView()),
        ),
      ),
    );
  }
}
