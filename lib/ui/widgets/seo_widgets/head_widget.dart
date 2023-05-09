import 'package:flutter/material.dart';
import 'package:seo/seo.dart';

class AppHead extends StatefulWidget {
  final String title;
  final String description;
  final String? schema;
  //final String? author;

  final Widget child;

  const AppHead({
    Key? key,
    required this.title,
    required this.description,
    this.schema,
    //this.author,
    required this.child,
  }) : super(key: key);

  @override
  State<AppHead> createState() => _AppHeadState();
}

class _AppHeadState extends State<AppHead> {
  final _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: widget.title),
        MetaTag(name: 'description', content: widget.description),
        // if (widget.author != null)
        //   MetaTag(name: 'author', content: widget.author),
      ],
      child: widget.child,
    );
  }
}
