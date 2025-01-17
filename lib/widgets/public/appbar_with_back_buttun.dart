import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

AppBar appBarWithBackButton(
    {required BuildContext context, required String title}) {
  return AppBar(
    // iconTheme: const IconThemeData(color: Colors.black),
    title: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    ),
    backgroundColor: AppStyle.secondaryColor,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    ),
    automaticallyImplyLeading: true,
  );
}
