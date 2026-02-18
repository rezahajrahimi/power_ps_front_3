import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerps/models/hiffify_config_model.dart';
import 'package:powerps/provider/panel_controller.dart';
import 'package:powerps/styles/app_theme.dart';

class HiddifyConfigDetailsWithCheckBoxWidget extends StatefulWidget {
  const HiddifyConfigDetailsWithCheckBoxWidget({super.key, required this.item});
  final HiddifyConfig item;

  @override
  State<HiddifyConfigDetailsWithCheckBoxWidget> createState() =>
      _HiddifyConfigDetailsWithCheckBoxWidgetState();
}

class _HiddifyConfigDetailsWithCheckBoxWidgetState
    extends State<HiddifyConfigDetailsWithCheckBoxWidget> {
  bool _isChecked = false;
  @override
  void initState() {
    _fillData();
    super.initState();
  }

  @override
  void dispose() {
    // _isChecked = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<PannelChangeController>(context, listen: false);
    _fillData();
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: _isChecked,
              onChanged: (value) {
                setState(() {
                  _isChecked = value ?? false;
                  // if value is not null and be true, add to _obtinedConfigList
                  if (value == true) {
                    Provider.of<PannelChangeController>(context, listen: false)
                        .addNewConfig(widget.item);
                  } else {
                    Provider.of<PannelChangeController>(context, listen: false)
                        .removeConfig(widget.item);
                  }
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppStyle.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item.name.length > 25
                            ? widget.item.name.substring(0, 25)
                            : widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.item.usageLimitGB} GB",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.white70),
                      ),
                      Text(
                        "${widget.item.packageDays}روزه",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fillData() async {
    setState(() {
      _isChecked = Provider.of<PannelChangeController>(context, listen: false)
          .checkIsConfigExist(widget.item);
    });
  }
}
