import 'package:flutter/material.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';
import 'package:powerps/models/log_model.dart';

DataRow recentEventDataRow(Log event) {
  final createdAtDateTime = (event.createdAt == null ||
          event.createdAt == 'null' ||
          event.createdAt!.trim().isEmpty)
      ? null
      : DateTime.tryParse(event.createdAt!.trim());
  final createdAt = (event.createdAt == null ||
          event.createdAt == 'null' ||
          event.createdAt!.trim().isEmpty)
      ? '—'
      : (createdAtDateTime != null
          ? '${createdAtDateTime.toPersianDate()} ${createdAtDateTime.hour}:${createdAtDateTime.minute}'
          : event.createdAt!.trim());
  final details = (event.message != null &&
          event.message != 'null' &&
          event.message!.trim().isNotEmpty)
      ? event.message!.trim()
      : (event.event != null &&
              event.event != 'null' &&
              event.event!.trim().isNotEmpty)
          ? event.event!.trim()
          : '—';

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
      DataCell(Text("${event.accountId}")),
      DataCell(Text(createdAt)),
      DataCell(Text(details)),
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
