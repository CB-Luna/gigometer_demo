import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

// E N V
const String strapiUrl = String.fromEnvironment(
  'strapiUrl',
  defaultValue: 'https://strapi-rta.cbluna-dev.com',
);

class GraphQLConfiguration {
  static HttpLink httpLink = HttpLink(
    '$strapiUrl/graphql',
  );

  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    ),
  );

  static ValueNotifier<GraphQLClient> clientToQuery() {
    return client;
  }
}

String setPath(String? path) {
  if (path != null) {
    return strapiUrl + path;
  } else {
    return 'https://i.stack.imgur.com/GNhx0';
  }
}
