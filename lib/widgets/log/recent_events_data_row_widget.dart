import 'package:flutter/material.dart';
import 'package:powerps/models/log_model.dart';

DataRow recentEventDataRow(Log event) {
  return DataRow(
    cells: [
      // DataCell(
      //   Row(
      //     children: [
      //       selectEventIcon(type: event.type!),
      //       Padding(
      //         padding:
      //             EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
      //         child: Text("${selectEventTitle(type: event.type!)}"),
      //       ),
      //     ],
      //   ),
      // ),
      DataCell(Text("${event.username} - ${event.accountId}")),
      DataCell(Text(event.createdAt!)),
      DataCell(Text(event.message!)),
    ],
  );
}

Icon selectEventIcon({required String type}) {
  IconData iconData = Icons.check;
  Icon icon = Icon(
    iconData,
    color: Colors.green,
  );

  if (type.contains('add')) {
    IconData iconDataAdd = Icons.add;

    icon = Icon(
      iconDataAdd,
      color: Colors.green[100],
    );
    return icon;
  }
  if (type.contains('inc')) {
    IconData iconDataAdd = Icons.add;

    icon = Icon(
      iconDataAdd,
      color: Colors.green[100],
    );
    return icon;
  }
  if (type.contains('dec')) {
    IconData iconDataAdd = Icons.remove;

    icon = Icon(
      iconDataAdd,
      color: Colors.red,
    );
    return icon;
  }
  if (type.contains('del')) {
    IconData iconDataDel = Icons.delete;

    icon = Icon(
      iconDataDel,
      color: Colors.red,
    );
    return icon;
  }
  if (type.contains('edit')) {
    IconData iconDataEdit = Icons.edit;

    icon = Icon(
      iconDataEdit,
      color: Colors.blue,
    );
    return icon;
  }
  if (type.contains('order')) {
    IconData iconDataEdit = Icons.list;

    icon = Icon(
      iconDataEdit,
      color: Colors.blue,
    );
    return icon;
  }
  if (type.contains('login')) {
    IconData iconDataLogin = Icons.login;

    icon = Icon(
      iconDataLogin,
      color: Colors.blue,
    );

    return icon;
  }
  if (type.contains('logout')) {
    IconData iconDataLogout = Icons.logout;

    icon = Icon(
      iconDataLogout,
      color: Colors.yellow,
    );
    return icon;
  } else {
    return icon;
  }
}

selectEventTitle({required String type}) {
  String title = "مشاهده";

  if (type.contains('add')) {
    title = "افزودن";
  }
  if (type.contains('inc')) {
    title = "افزودن";
  }
  if (type.contains('del')) {
    title = "حذف";
  }
  if (type.contains('dec')) {
    title = "حذف";
  }
  if (type.contains('order')) {
    title = "سفارش";
  }
  if (type.contains('edit')) {
    title = "ویرایش";
  }
  if (type.contains('login')) {
    title = "ورود به پلاک سنگ";
  }
  if (type.contains('logout')) {
    title = "خروج از پلاک سنگ";
  }
  if (type.contains('cut')) {
    title = "مصرف کوپ";
  }

  return title;
}
