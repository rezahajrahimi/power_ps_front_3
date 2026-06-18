import 'package:flutter/material.dart';
import 'package:powerps/styles/app_theme.dart';

class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({
    super.key,
    required this.searchHint,
    required this.searchQuery,
    required this.onSearchChanged,
    this.locationOptions = const [],
    this.selectedLocation,
    this.onLocationChanged,
    this.panelOptions = const [],
    this.selectedPanel,
    this.onPanelChanged,
    this.dayOptions = const [],
    this.selectedDay,
    this.onDayChanged,
    this.volumeOptions = const [],
    this.selectedVolume,
    this.onVolumeChanged,
    this.sortOptions = const [],
    this.selectedSort,
    this.onSortChanged,
    this.statusOptions = const [],
    this.selectedStatus,
    this.onStatusChanged,
  });

  final String searchHint;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<String> locationOptions;
  final String? selectedLocation;
  final ValueChanged<String?>? onLocationChanged;
  final List<MapEntry<String, String>> panelOptions;
  final String? selectedPanel;
  final ValueChanged<String?>? onPanelChanged;
  final List<MapEntry<String, String>> dayOptions;
  final String? selectedDay;
  final ValueChanged<String?>? onDayChanged;
  final List<MapEntry<String, String>> volumeOptions;
  final String? selectedVolume;
  final ValueChanged<String?>? onVolumeChanged;
  final List<MapEntry<String, String>> sortOptions;
  final String? selectedSort;
  final ValueChanged<String?>? onSortChanged;
  final List<MapEntry<String, String>> statusOptions;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusChanged;

  bool get _hasDropdowns =>
      locationOptions.isNotEmpty ||
      panelOptions.isNotEmpty ||
      dayOptions.isNotEmpty ||
      volumeOptions.isNotEmpty ||
      sortOptions.isNotEmpty ||
      statusOptions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_hasDropdowns) ...[
          SizedBox(height: AppStyle.defaultPadding / 2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (locationOptions.isNotEmpty && onLocationChanged != null)
                _dropdown(
                  label: 'موقعیت',
                  value: selectedLocation,
                  items: ['همه', ...locationOptions],
                  onChanged: (value) =>
                      onLocationChanged!(value == 'همه' ? null : value),
                ),
              if (panelOptions.isNotEmpty && onPanelChanged != null)
                _dropdown(
                  label: 'پنل',
                  value: selectedPanel,
                  items: ['همه', ...panelOptions.map((e) => e.key)],
                  labels: {
                    'همه': 'همه',
                    for (final e in panelOptions) e.key: e.value,
                  },
                  onChanged: (value) =>
                      onPanelChanged!(value == 'همه' ? null : value),
                ),
              if (dayOptions.isNotEmpty && onDayChanged != null)
                _dropdown(
                  label: 'روز',
                  value: selectedDay,
                  items: ['همه', ...dayOptions.map((e) => e.key)],
                  labels: {
                    'همه': 'همه',
                    for (final e in dayOptions) e.key: e.value,
                  },
                  onChanged: (value) =>
                      onDayChanged!(value == 'همه' ? null : value),
                ),
              if (volumeOptions.isNotEmpty && onVolumeChanged != null)
                _dropdown(
                  label: 'حجم',
                  value: selectedVolume,
                  items: ['همه', ...volumeOptions.map((e) => e.key)],
                  labels: {
                    'همه': 'همه',
                    for (final e in volumeOptions) e.key: e.value,
                  },
                  onChanged: (value) =>
                      onVolumeChanged!(value == 'همه' ? null : value),
                ),
              if (sortOptions.isNotEmpty && onSortChanged != null)
                _dropdown(
                  label: 'مرتب‌سازی',
                  value: selectedSort ?? sortOptions.first.key,
                  items: sortOptions.map((e) => e.key).toList(),
                  labels: {for (final e in sortOptions) e.key: e.value},
                  onChanged: onSortChanged!,
                ),
              if (statusOptions.isNotEmpty && onStatusChanged != null)
                _dropdown(
                  label: 'وضعیت',
                  value: selectedStatus ?? statusOptions.first.key,
                  items: statusOptions.map((e) => e.key).toList(),
                  labels: {for (final e in statusOptions) e.key: e.value},
                  onChanged: onStatusChanged!,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? labels,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 180,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      labels?[item] ?? item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
