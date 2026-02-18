import 'dart:convert';
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
      if (mounted) {
        showMsg(msg: "خطا در دریافت اطلاعات", context: context, type: "error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 1;
                              if (constraints.maxWidth > 1200) {
                                crossAxisCount = 3;
                              } else if (constraints.maxWidth > 800) {
                                crossAxisCount = 2;
                              }

                              if (crossAxisCount > 1) {
                                return GridView.builder(
                                  padding:
                                      EdgeInsets.all(AppStyle.defaultPadding),
                                  itemCount: _messages.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: AppStyle.defaultPadding,
                                    mainAxisSpacing: AppStyle.defaultPadding,
                                    mainAxisExtent:
                                        560, // افزایش ارتفاع برای جلوگیری از سرریزی
                                  ),
                                  itemBuilder: (context, index) {
                                    final msg = _messages[index];
                                    return _buildMessageCard(msg);
                                  },
                                );
                              }

                              return ListView.builder(
                                padding:
                                    EdgeInsets.all(AppStyle.defaultPadding),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final msg = _messages[index];
                                  return _buildMessageCard(msg);
                                },
                              );
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
                              onPageChanged: (page) =>
                                  _fetchMessages(page: page),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black12,
                    child: Image.network(
                      "$baseURL/${msg['image_path']}",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white30)),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (msg['message'] != null)
                  Text(
                    msg['message'],
                    maxLines: 2,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                              color:
                                  AppStyle.primaryColor.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _showDetails(msg),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text("جزئیات ارسال"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(dynamic msg) {
    // Prefer detailed user info from API if available
    List<dynamic> sentUsers = [];
    List<dynamic> failedUsers = [];

    List<dynamic> recipients = [];
    try {
      if (msg['sent_users_detail'] != null &&
          msg['sent_users_detail'] is List) {
        sentUsers = List.from(msg['sent_users_detail']);
      } else if (msg['sent_ids'] != null) {
        if (msg['sent_ids'] is String) {
          sentUsers = jsonDecode(msg['sent_ids']);
        } else {
          sentUsers = List.from(msg['sent_ids']);
        }
      }

      if (msg['failed_users_detail'] != null &&
          msg['failed_users_detail'] is List) {
        failedUsers = List.from(msg['failed_users_detail']);
      } else if (msg['failed_ids'] != null) {
        if (msg['failed_ids'] is String) {
          failedUsers = jsonDecode(msg['failed_ids']);
        } else {
          failedUsers = List.from(msg['failed_ids']);
        }
      }

      if (msg['recipient_details'] != null &&
          msg['recipient_details'] is List) {
        recipients = List.from(msg['recipient_details']);
      } else if (msg['recipient_ids'] != null) {
        if (msg['recipient_ids'] is String) {
          recipients = jsonDecode(msg['recipient_ids']);
        } else {
          recipients = List.from(msg['recipient_ids']);
        }
      }
    } catch (e) {
      debugPrint("Error decoding ids: $e");
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppStyle.secondaryColor,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: 600,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "جزئیات ارسال پیام",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: AppStyle.primaryColor,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white30,
                      tabs: [
                        Tab(text: "گیرندگان (${recipients.length})"),
                        Tab(text: "موفق (${sentUsers.length})"),
                        Tab(text: "ناموفق (${failedUsers.length})"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildRecipientList(recipients),
                          _buildUserList(sentUsers),
                          _buildFailedUserList(failedUsers),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List users) {
    if (users.isEmpty) {
      return const Center(
          child:
              Text("دیتا یافت نشد", style: TextStyle(color: Colors.white30)));
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final u = users[index];
        String display = '';
        String subtitle = '';
        if (u is Map) {
          final fn = (u['first_name'] ?? '').toString();
          final ln = (u['last_name'] ?? '').toString();
          final username = (u['username'] ?? '').toString();
          final acc = (u['account_id'] ?? u['user_id'] ?? '').toString();
          if (fn.isNotEmpty || ln.isNotEmpty) {
            display = '$fn $ln';
          } else if (username.isNotEmpty)
            display = '@$username';
          else
            display = 'شناسه: $acc';
          if (username.isNotEmpty) {
            subtitle = '@$username';
          } else {
            subtitle = 'شناسه: $acc';
          }
        } else {
          display = u.toString();
        }
        return ListTile(
          title: Text(display, style: const TextStyle(color: Colors.white70)),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12))
              : null,
          leading: const Icon(Icons.check_circle, color: Colors.greenAccent),
        );
      },
    );
  }

  Widget _buildRecipientList(List items) {
    if (items.isEmpty) {
      return const Center(
          child:
              Text("دیتا یافت نشد", style: TextStyle(color: Colors.white30)));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        String title = '';
        String subtitle = '';
        String status = '';
        Color statusColor = Colors.white30;
        if (item is Map) {
          final fn = (item['first_name'] ?? '').toString();
          final ln = (item['last_name'] ?? '').toString();
          final username = (item['username'] ?? '').toString();
          final acc = (item['account_id'] ?? item['user_id'] ?? '').toString();
          if (fn.isNotEmpty || ln.isNotEmpty) {
            title = '$fn $ln';
          } else if (username.isNotEmpty)
            title = '@$username';
          else
            title = 'شناسه: $acc';
          subtitle = username.isNotEmpty ? '@$username' : 'شناسه: $acc';
          status = (item['status'] ?? '').toString();
          if (status == 'sent') {
            statusColor = Colors.greenAccent;
          } else if (status == 'failed') statusColor = Colors.redAccent;
        } else {
          title = item.toString();
        }
        return ListTile(
          title: Text(title, style: const TextStyle(color: Colors.white70)),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12))
              : null,
          leading: Icon(Icons.person, color: statusColor),
        );
      },
    );
  }

  Widget _buildFailedUserList(List items) {
    if (items.isEmpty) {
      return const Center(
          child:
              Text("دیتا یافت نشد", style: TextStyle(color: Colors.white30)));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        String title = '';
        String subtitle = '';
        if (item is Map) {
          final fn = (item['first_name'] ?? '').toString();
          final ln = (item['last_name'] ?? '').toString();
          final username = (item['username'] ?? '').toString();
          final acc = (item['account_id'] ?? item['user_id'] ?? '').toString();
          if (fn.isNotEmpty || ln.isNotEmpty) {
            title = '$fn $ln';
          } else if (username.isNotEmpty)
            title = '@$username';
          else
            title = 'شناسه: $acc';
          subtitle = item['error'] ?? 'خطای نامشخص';
        } else {
          title = item.toString();
        }
        return ListTile(
          title: Text(title, style: const TextStyle(color: Colors.white70)),
          subtitle: Text(subtitle,
              style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
          leading: const Icon(Icons.error, color: Colors.redAccent),
        );
      },
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
