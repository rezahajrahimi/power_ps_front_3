import 'package:flutter/material.dart';
import 'package:powerps/models/log_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:powerps/widgets/log/recent_events_data_row_widget.dart';

class RecentEvents extends StatefulWidget {
  final String type;
  final List<Log> events;
  const RecentEvents({super.key, required this.type, required this.events});

  @override
  State<RecentEvents> createState() => _RecentEventsState();
}

class _RecentEventsState extends State<RecentEvents> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "آخرین فعالیت ها",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            height: widget.type == "dashboard" ? 400 : 800,
            child: DataTable2(
              columnSpacing: AppStyle.defaultPadding,
              minWidth: 600,
              columns: const [
                // DataColumn(
                //   label: Text("نام فعالیت"),
                // ),
                DataColumn(
                  label: Text("کاربر"),
                ),
                DataColumn(
                  label: Text("زمان"),
                ),
                DataColumn(
                  label: Text("جزییات"),
                ),
              ],
              rows: List.generate(
                widget.events.length,
                (index) => recentEventDataRow(widget.events[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
