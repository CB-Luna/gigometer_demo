import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

// E N V
const String strapiUrl = String.fromEnvironment(
  'strapiUrl',
  defaultValue: 'https://strapi.cblsrv43.rtatel.com',
);

const String envRoute = String.fromEnvironment(
  'envRoute',
  defaultValue: 'https://rtadev-ecom.cbluna-dev.com',
);

const String apiEnvDev = String.fromEnvironment(
  'apiEnvDev',
  defaultValue: 'https://gigometer43.rtatel.com',
);

const String apiEnvProd = String.fromEnvironment(
  'apiEnvProd',
  defaultValue: 'https://gigometer.net',
);

const String gigometerUrl = String.fromEnvironment(
  'gigometerUrl',
  defaultValue: 'https://gigometer43.rtatel.com/CustomSpeedTest/index.html',
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
