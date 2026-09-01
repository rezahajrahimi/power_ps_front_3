import 'package:powerps/widgets/public/place_holder_widget.dart';
import 'package:flutter/material.dart';

Widget commonCachedAssestImage(
  String? url, {
  double? height,
  double? width,
  BoxFit? fit,
  AlignmentGeometry? alignment,
  bool usePlaceholderIfUrlEmpty = true,
  double? radius,
  Color? color,
}) {
  if (url!.isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else {
    return Image.asset(
      url,
    );
  }
}
