import 'dart:async';

import 'package:flutter/material.dart';
import 'package:powerps/repositories/general_repository.dart';
import 'package:powerps/styles/app_theme.dart';

/// Loads a single panel's live status independently (won't block other dashboard widgets).
class PanelStatusTile extends StatefulWidget {
  final int panelId;
  final String? location;
  final String? type;
  final int? totalUsers;

  const PanelStatusTile({
    super.key,
    required this.panelId,
    this.location,
    this.type,
    this.totalUsers,
  });

  @override
  State<PanelStatusTile> createState() => _PanelStatusTileState();
}

class _PanelStatusTileState extends State<PanelStatusTile> {
  bool _loading = true;
  bool? _isOnline;
  int _onlineUsers = 0;
  int _totalUsers = 0;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _totalUsers = widget.totalUsers ?? 0;
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await getPanelDashboardStatus(widget.panelId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (data != null) {
        _isOnline = data['is_online'] == true;
        _onlineUsers = int.tryParse(data['online_users']?.toString() ?? '') ?? 0;
        _totalUsers = int.tryParse(data['total_users']?.toString() ?? '') ??
            widget.totalUsers ??
            0;
        _error = null;
      } else {
        _isOnline = false;
        _error = 'خطا در دریافت وضعیت';
      }
    });
  }

  Color _statusColor() {
    if (_loading) return Colors.orange;
    if (_isOnline == true) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location ?? 'نامشخص';
    final type = widget.type ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _statusColor().withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      type == 'hiddify'
                          ? Icons.security
                          : Icons.settings_input_component,
                      size: 16,
                      color: AppStyle.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor().withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (_error != null && !_loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white38, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'کل کاربران',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  Text(
                    '$_totalUsers',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'آنلاین',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  Text(
                    _loading ? '...' : '$_onlineUsers',
                    style: TextStyle(
                      color: AppStyle.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
