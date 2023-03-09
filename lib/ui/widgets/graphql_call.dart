import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DataCall extends StatelessWidget {
  final dynamic page;
  final String query;

  const DataCall({Key? key, required this.page, required this.query})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: gql(query),
          pollInterval: const Duration(seconds: 0),
        ),
        builder: (
          QueryResult result, {
          refetch,
          fetchMore,
        }) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const CircularProgressIndicator();
          } else {
            return page(result, context);
          }
        });
  }
}
