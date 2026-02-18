import 'package:flutter/material.dart';
import 'package:powerps/repositories/log_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:powerps/widgets/log/recent_events_list_widget.dart';

class LogsListScreen extends StatefulWidget {
  const LogsListScreen({super.key});

  @override
  State<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends State<LogsListScreen> {
  bool _isLoading = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _retriveData();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _retriveData(),
            color: AppStyle.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(AppStyle.defaultPadding),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: AppStyle.defaultPadding),
                    _isLoading
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppStyle.primaryColor,
                              ),
                            ),
                          )
                        : _content(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: AppStyle.primaryColor),
              const SizedBox(width: 10),
              Text(
                "گزارش رخدادها",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _retriveData(),
                icon: const Icon(Icons.refresh),
                tooltip: "بروزرسانی",
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "جستجو در رخدادها...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppStyle.bgColor.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }

  void _retriveData() async {
    setState(() => _isLoading = true);
    try {
      await getAllLogs(count: 400);
    } catch (e) {
      debugPrint("Error fetching logs: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  _content(BuildContext context) {
    if (lastLogList.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 60, color: Colors.grey.withValues(alpha: 0.5)),
              const SizedBox(height: 10),
              const Text("هیچ رخدادی ثبت نشده است",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final filteredLogs = lastLogList.where((log) {
      final query = _searchQuery.toLowerCase();
      return (log.username?.toLowerCase().contains(query) ?? false) ||
          (log.message?.toLowerCase().contains(query) ?? false) ||
          (log.createdAt?.toLowerCase().contains(query) ?? false) ||
          (log.accountId.toString().contains(query));
    }).toList();

    if (filteredLogs.isEmpty && _searchQuery.isNotEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off,
                  size: 60, color: Colors.grey.withValues(alpha: 0.5)),
              const SizedBox(height: 10),
              const Text("رخدادی با این مشخصات یافت نشد",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: RecentEvents(type: "fullList", events: filteredLogs),
            ),
          ],
        )
      ],
    );
  }
}
