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
  final List<MapEntry<String, String>> sortOptions;
  final String? selectedSort;
  final ValueChanged<String?>? onSortChanged;
  final List<MapEntry<String, String>> statusOptions;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusChanged;

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
        if (locationOptions.isNotEmpty ||
            sortOptions.isNotEmpty ||
            statusOptions.isNotEmpty) ...[
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
