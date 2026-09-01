import 'package:flutter/material.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/models/proxy_model.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/public/custom_switch_widget.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';

class MarzbanInboundToggle {
  MarzbanInboundToggle({
    required this.protocol,
    required this.tag,
    this.enabled = true,
  });

  final String protocol;
  final String tag;
  bool enabled;
}

class MarzbanProxySettings {
  final List<MarzbanInboundToggle> inbounds = [];

  bool get isLoaded => inbounds.isNotEmpty;

  void loadFromPanel(Map<String, List<String>> panelInbounds) {
    inbounds.clear();
    panelInbounds.forEach((protocol, tags) {
      for (final tag in tags) {
        if (tag.trim().isEmpty) continue;
        inbounds.add(
          MarzbanInboundToggle(
            protocol: protocol.toLowerCase(),
            tag: tag,
            enabled: true,
          ),
        );
      }
    });
  }

  void applyFromSavedProxies(List<Proxy> proxies) {
    final saved = <String, bool>{};
    for (final proxy in proxies) {
      for (final inbound in proxy.inbounds ?? []) {
        saved[inbound.name] = inbound.isActive;
      }
    }
    for (final item in inbounds) {
      if (saved.containsKey(item.tag)) {
        item.enabled = saved[item.tag]!;
      }
    }
  }

  List<Map<String, dynamic>> toApiPayload() {
    return inbounds
        .map((e) => {
              'protocol': e.protocol,
              'tag': e.tag,
              'enabled': e.enabled,
            })
        .toList();
  }

  Map<String, List<MarzbanInboundToggle>> get groupedByProtocol {
    final map = <String, List<MarzbanInboundToggle>>{};
    for (final item in inbounds) {
      map.putIfAbsent(item.protocol, () => []).add(item);
    }
    return map;
  }

  String protocolLabel(String protocol) => protocol.toUpperCase();
}

class MarzbanProxiesCard extends StatelessWidget {
  const MarzbanProxiesCard({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final MarzbanProxySettings settings;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (!settings.isLoaded) {
      return Container(
        padding: EdgeInsets.all(AppStyle.defaultPadding),
        decoration: BoxDecoration(
          color: AppStyle.secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          'پس از «بررسی اتصال»، inboundهای فعال پنل مرزبان اینجا نمایش داده می‌شوند.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final groups = settings.groupedByProtocol.entries.toList();
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
            'Inboundهای پنل مرزبان',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppStyle.defaultPadding),
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0)
              Divider(
                thickness: 5,
                color: AppStyle.primaryColor.withValues(alpha: 0.15),
              ),
            Text(
              settings.protocolLabel(groups[i].key),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: AppStyle.defaultPadding / 2),
            _grid(
              context,
              groups[i].value
                  .map(
                    (item) => CustomSwitchWidget(
                      title: item.tag,
                      val: item.enabled,
                      callback: (val) {
                        item.enabled = val;
                        onChanged();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _grid(BuildContext context, List<Widget> items) {
    return SizedBox(
      width: double.infinity,
      child: Responsive(
        mobile: widgetsGridview(
            childAspectRatio: 2.9, context: context, importedList: items),
        tablet: widgetsGridview(
            context: context, childAspectRatio: 6, importedList: items),
        desktop: widgetsGridview(
            importedList: items,
            context: context,
            childAspectRatio: 6,
            crossAxisCount: 2),
      ),
    );
  }
}
