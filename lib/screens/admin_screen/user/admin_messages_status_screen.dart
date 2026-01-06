import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/repositories/bot_user_repository.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:persian_datetimepickers/persian_datetimepickers.dart';

class AdminMessagesStatusScreen extends StatefulWidget {
  const AdminMessagesStatusScreen({super.key});

  @override
  State<AdminMessagesStatusScreen> createState() =>
      _AdminMessagesStatusScreenState();
}

class _AdminMessagesStatusScreenState extends State<AdminMessagesStatusScreen> {
  bool _isLoading = true;
  List<dynamic> _messages = [];
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void initState() {
    _fetchMessages();
    super.initState();
  }

  Future<void> _fetchMessages({int page = 1}) async {
    setState(() => _isLoading = true);
    final result = await getAdminMessages(page: page);
    if (result != null) {
      setState(() {
        _messages = result['data'];
        _currentPage = result['current_page'];
        _lastPage = result['last_page'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted)
        showMsg(msg: "خطا در دریافت اطلاعات", context: context, type: "error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyle.secondaryColor,
          title: const Text("وضعیت پیام‌های ارسالی",
              style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _fetchMessages(page: _currentPage),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _messages.isEmpty
                ? const Center(
                    child: Text("هیچ پیامی یافت نشد",
                        style: TextStyle(color: Colors.white70)))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(AppStyle.defaultPadding),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return _buildMessageCard(msg);
                          },
                        ),
                      ),
                      if (_lastPage > 1)
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: AppStyle.defaultPadding),
                          color: AppStyle.secondaryColor,
                          child: Pagination(
                            numOfPages: _lastPage,
                            selectedPage: _currentPage,
                            pagesVisible: 5,
                            onPageChanged: (page) => _fetchMessages(page: page),
                            nextIcon: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 14),
                            previousIcon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 14),
                            activeTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            activeBtnStyle: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  AppStyle.primaryColor),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            inactiveBtnStyle: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              )),
                              backgroundColor: WidgetStateProperty.all(
                                  Colors.white.withValues(alpha: 0.05)),
                            ),
                            inactiveTextStyle:
                                const TextStyle(color: Colors.white70),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMessageCard(dynamic msg) {
    final status = msg['status'] ?? 'pending';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.greenAccent;
        statusText = "پایان یافته";
        break;
      case 'processing':
        statusColor = Colors.blueAccent;
        statusText = "در حال ارسال";
        break;
      case 'failed':
        statusColor = Colors.redAccent;
        statusText = "خطا";
        break;
      default:
        statusColor = Colors.orangeAccent;
        statusText = "در صف";
    }

    final int total = msg['total_users'] ?? 0;
    final int sent = msg['sent_users'] ?? 0;
    final double progress = total > 0 ? sent / total : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  msg['created_at'] != null
                      ? DateTime.parse(msg['created_at']).toPersianDate()
                      : '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => _showDeleteConfirm(msg['id']),
                ),
              ],
            ),
          ),
          if (msg['image_path'] != null)
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(baseURL + "/" + msg['image_path']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg['message'] != null)
                  Text(
                    msg['message'],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("پیشرفت: $sent از $total",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text("${(progress * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppStyle.secondaryColor,
        title: const Text("حذف رکورد", style: TextStyle(color: Colors.white)),
        content: const Text(
            "آیا از حذف این رکورد اطمینان دارید؟ این عمل باعث توقف پیام در حال ارسال نمی‌شود.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("خیر")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              EasyLoading.show();
              final ok = await deleteAdminMessage(id);
              EasyLoading.dismiss();
              if (ok) {
                _fetchMessages(page: _currentPage);
              }
            },
            child: const Text("بله", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
