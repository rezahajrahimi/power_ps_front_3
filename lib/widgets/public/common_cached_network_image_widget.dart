import 'package:flutter/material.dart';
import 'package:powerps/widgets/public/place_holder_widget.dart';

Widget commonCachedNetworkImage(
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
  } else if (url.startsWith('http')) {
    return Image.network(
      url,
    );
  } else {
    return Container(
      color: Colors.white,
    );
  }
}
