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
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                "آخرین فعالیت ها",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: widget.type == "dashboard" ? 400 : 1000,
            child: DataTable2(
              columnSpacing: AppStyle.defaultPadding,
              minWidth: 600,
              headingRowHeight: 40,
              dataRowHeight: 60,
              columns: const [
                DataColumn2(
                  label: Text("کاربر",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text("زمان",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text("جزییات",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.L,
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
