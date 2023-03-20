import 'package:flutter/material.dart';
import 'package:speed_test/ui/widgets/circular_container.dart';

import '../../../services/graphql_config.dart';

class CarImage extends StatelessWidget {
  final String url;

  const CarImage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Stack(alignment: Alignment.center, children: [
          const CircularContainer(child: SizedBox.shrink()),
          Image.network(setPath(url))
        ]),
      ),
    );
  }
}
