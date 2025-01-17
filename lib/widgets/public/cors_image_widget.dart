// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
// import 'dart:html' as html;

// class CorsImageWidget extends StatelessWidget {
//   const CorsImageWidget({super.key, required this.imageUrl});
//   final String imageUrl;

//   @override
//   Widget build(BuildContext context) {
//     // String imageUrl = "image_url";
//     // https://github.com/flutter/flutter/issues/41563
//     // ignore: undefined_prefixed_name
//     ui.platformViewRegistry.registerViewFactory(
//       imageUrl,
//       (int _) => html.ImageElement()..src = imageUrl,
//     );
//     return HtmlElementView(
//       viewType: imageUrl,
//     );
//   }
// }
