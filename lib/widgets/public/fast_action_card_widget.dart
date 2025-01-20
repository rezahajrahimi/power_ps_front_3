import 'package:flutter/material.dart';

class FastActionCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  // add function
  final Function function;
  const FastActionCardWidget(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.iconData,
      required this.function});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => function(),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Icon(iconData),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => function(),
          ),
        ),
      ),
    );
  }
}
