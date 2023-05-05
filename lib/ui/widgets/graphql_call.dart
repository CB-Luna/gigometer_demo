import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DataCall extends StatelessWidget {
  final String query;
  final Widget Function(QueryResult query, BuildContext context) page;

  const DataCall({
    Key? key,
    required this.query,
    required this.page,
  }) : super(key: key);

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
            return page(result, context);
          }

          if (result.isLoading) {
            return const CircularProgressIndicator();
          }

          return page(result, context);
        });
  }
}
