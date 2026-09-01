import 'package:powerps/styles/app_theme.dart';
import 'package:flutter/material.dart';

widgetsGridview(
    {required BuildContext context,
    required List<Widget> importedList,
    int crossAxisCount = 1,
    double childAspectRatio = 1}) {
  return GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: importedList.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: AppStyle.defaultPadding,
      mainAxisSpacing: AppStyle.defaultPadding,
      childAspectRatio: childAspectRatio,
    ),
    itemBuilder: (context, index) => importedList[index],

    // MaxCubeItemWithImage(cube: widget.cubeInfoItemList[index]),
  );
}
