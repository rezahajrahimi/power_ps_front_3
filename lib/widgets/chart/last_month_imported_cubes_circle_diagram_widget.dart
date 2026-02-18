import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/models/details_info.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/details_info_item_widget.dart';

class CirckeChartInfoCard extends StatefulWidget {
  final String title, chartText;
  final List<DetailsInfoItem> listData;

  const CirckeChartInfoCard({
    super.key,
    required this.title,
    required this.listData,
    required this.chartText,
  });

  @override
  State<CirckeChartInfoCard> createState() => _CirckeChartInfoCardState();
}

class _CirckeChartInfoCardState extends State<CirckeChartInfoCard> {
  // int _totalProducts = 0;
  int _totalsell = 0;
  bool _showData = false;
  @override
  void initState() {
    _fillData();
    super.initState();
  }

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
      child: _showData == true
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppStyle.defaultPadding * 3),
                chart(context),
                SizedBox(height: AppStyle.defaultPadding * 3),
                for (var i in widget.listData) DetailsInfoItemWidget(item: i),
              ],
            )
          : const Opacity(opacity: 0),
    );
  }

  chart(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: paiChartSelectionDatas,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppStyle.defaultPadding),
                Text(
                  _totalsell.toString(),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 0.5,
                      ),
                ),
                Text(
                  " ${widget.chartText}",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> paiChartSelectionDatas = [];

  void _fillData() async {
    await SharedPreferences.getInstance().then((value) {
      if (widget.listData.isNotEmpty) {
        // setState(() {
        //   _totalProducts = widget.listData.fold(0, (a, b) => a + 1);
        // });
        setState(() {
          _totalsell = widget.listData
              .fold<int>(0, (a, b) => a + int.parse(b.itemValue));
        });
        for (var i in widget.listData) {
          paiChartSelectionDatas.add(PieChartSectionData(
            color: randomColorGenerator(),
            value: double.parse(i.itemValue),
            showTitle: false,
            radius: ((int.parse(i.itemValue)) / _totalsell) * 70,
          ));
        }
        setState(() {
          _showData = true;
        });
      }
    });
  }
}
