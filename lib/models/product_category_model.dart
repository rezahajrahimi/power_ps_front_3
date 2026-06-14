import 'dart:convert';

import 'package:powerps/models/agent_add_categoriy_model.dart';
import 'package:powerps/models/pannel_model.dart';

class ProductCategory {
  int id;
  int pannelId;
  int? categoryTypeId;
  String categoryName;
  int price;
  double priceInDollar;
  int expireDay;
  int volume;
  bool rechargable = true;
  bool showSubscriptionLink = true;
  bool showPannelLink = true;
  bool sendConfigToUser = true;
  bool isActive = true;
  /// If null/empty => visible/buyable for all groups.
  /// Uses `0` as sentinel for "بدون گروه".
  List<int>? allowedUserGroupIds;
  int? inboundId;
  int? ipLimit;
  String? sampleInbound;
  Pannel? pannel;
  AgentAddCategoriyModel? agentAddCategoriyModel;

  ProductCategory({
    required this.id,
    required this.pannelId,
    this.categoryTypeId,
    required this.categoryName,
    required this.price,
    required this.priceInDollar,
    required this.expireDay,
    required this.volume,
    required this.rechargable,
    required this.showSubscriptionLink,
    required this.showPannelLink,
    required this.sendConfigToUser,
    required this.isActive,
    this.allowedUserGroupIds,
    this.inboundId,
    this.ipLimit,
    this.sampleInbound,
    this.pannel,
    this.agentAddCategoriyModel,
  });

  bool isAllowedForUserGroup(int? userGroupId) {
    final allowed = allowedUserGroupIds;
    if (allowed == null || allowed.isEmpty) return true;
    final normalized = userGroupId ?? 0;
    return allowed.contains(normalized);
  }

  ProductCategory copyWith({
    int? id,
    int? pannelId,
    int? categoryType,
    String? categoryName,
    int? price,
    double? priceInDollar,
    int? expireDay,
    int? volume,
    bool? rechargable,
    bool? showSubscriptionLink,
    bool? showPannelLink,
    bool? sendConfigToUser,
    bool? isActive,
    List<int>? allowedUserGroupIds,
    int? inboundId,
    int? ipLimit,
    String? sampleInbound,
    AgentAddCategoriyModel? agentAddCategoriyModel,
    Pannel? pannel,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      pannelId: pannelId ?? this.pannelId,
      categoryTypeId: categoryTypeId ?? categoryTypeId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      priceInDollar: priceInDollar ?? this.priceInDollar,
      expireDay: expireDay ?? this.expireDay,
      volume: volume ?? this.volume,
      rechargable: rechargable ?? this.rechargable,
      showSubscriptionLink: showSubscriptionLink ?? this.showSubscriptionLink,
      showPannelLink: showPannelLink ?? this.showPannelLink,
      sendConfigToUser: sendConfigToUser ?? this.sendConfigToUser,
      isActive: isActive ?? this.isActive,
      allowedUserGroupIds: allowedUserGroupIds ?? this.allowedUserGroupIds,
      inboundId: inboundId ?? this.inboundId,
      ipLimit: ipLimit ?? this.ipLimit,
      sampleInbound: sampleInbound ?? this.sampleInbound,
      agentAddCategoriyModel:
          agentAddCategoriyModel ?? this.agentAddCategoriyModel,
      pannel: pannel ?? this.pannel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pannelId': pannelId,
      'categoryTypeId': categoryTypeId,
      'categoryName': categoryName,
      'price': price,
      'priceInDollar': priceInDollar,
      'expireDay': expireDay,
      'volume': volume,
      'rechargable': rechargable,
      'showSubscriptionLink': showSubscriptionLink,
      'showPannelLink': showPannelLink,
      'sendConfigToUser': sendConfigToUser,
      'isActive': isActive,
      'allowed_user_group_ids': allowedUserGroupIds,
      'inbound_id': inboundId,
      'ip_limit': ipLimit,
      'sample_inbound': sampleInbound,
      // 'agentAddCategoriyModel': agentAddCategoriyModel?.toMap(),
      // 'pannel': pannel?,
    };
  }

  static List<int>? _parseAllowedGroupIds(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      final out = <int>[];
      for (final v in raw) {
        final i = int.tryParse(v.toString());
        if (i != null) out.add(i);
      }
      return out;
    }
    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return null;
      final parts = s.split(RegExp(r'[,; ]+')).where((p) => p.trim().isNotEmpty);
      final out = <int>[];
      for (final p in parts) {
        final i = int.tryParse(p.trim());
        if (i != null) out.add(i);
      }
      return out;
    }
    return null;
  }

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
        id: map['id']?.toInt() ?? 0,
        pannelId: map['pannel_id']?.toInt() ?? 0,
        categoryTypeId: map['category_type_id']?.toInt() ?? 0,
        categoryName: map['category_name'] ?? '',
        price: map['price']?.toInt() ?? 0,
        priceInDollar: map['price_in_dollar']?.toDouble() ?? 0.0,
        expireDay: map['expire_day']?.toInt() ?? 0,
        volume: map['volume']?.toInt() ?? 0,
        rechargable: map['rechargable'] == 1 ? true : false,
        showSubscriptionLink: map['show_subscription_link'] == 1 ? true : false,
        showPannelLink: map['show_pannel_link'] == 1 ? true : false,
        sendConfigToUser: map['send_config_to_user'] == null
            ? true
            : map['send_config_to_user'] == 1,
        isActive: map['is_active'] == 1 ? true : false,
        allowedUserGroupIds: _parseAllowedGroupIds(map['allowed_user_group_ids']),
        inboundId: map['inbound_id']?.toInt(),
        ipLimit: map['ip_limit']?.toInt(),
        sampleInbound: map['sample_inbound']?.toString(),
        pannel: map['pannel'] != null ? Pannel.fromJson(map['pannel']) : null,
        agentAddCategoriyModel: map['agentAddCategoriyModel'] != null
            ? AgentAddCategoriyModel.fromMap(map['agentAddCategoriyModel'])
            : null);
  }

  factory ProductCategory.fromJson(String source) =>
      ProductCategory.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProductCategory(id: $id, pannelId: $pannelId, categoryName: $categoryName, price: $price, priceInDollar: $priceInDollar, expireDay: $expireDay, volume: $volume, rechargable: $rechargable, showSubscriptionLink: $showSubscriptionLink, showPannelLink: $showPannelLink, sendConfigToUser: $sendConfigToUser, isActive: $isActive, sampleInbound: $sampleInbound, agentAddCategoriyModel: $agentAddCategoriyModel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductCategory &&
        other.id == id &&
        other.pannelId == pannelId &&
        other.categoryTypeId == categoryTypeId &&
        other.categoryName == categoryName &&
        other.price == price &&
        other.priceInDollar == priceInDollar &&
        other.expireDay == expireDay &&
        other.volume == volume &&
        other.rechargable == rechargable &&
        other.showSubscriptionLink == showSubscriptionLink &&
        other.showPannelLink == showPannelLink &&
        other.sendConfigToUser == sendConfigToUser &&
        other.isActive == isActive &&
        other.inboundId == inboundId &&
        other.ipLimit == ipLimit &&
        other.sampleInbound == sampleInbound &&
        other.agentAddCategoriyModel == agentAddCategoriyModel;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pannelId.hashCode ^
        categoryTypeId.hashCode ^
        categoryName.hashCode ^
        price.hashCode ^
        priceInDollar.hashCode ^
        expireDay.hashCode ^
        volume.hashCode ^
        rechargable.hashCode ^
        showSubscriptionLink.hashCode ^
        showPannelLink.hashCode ^
        sendConfigToUser.hashCode ^
        isActive.hashCode ^
        inboundId.hashCode ^
        ipLimit.hashCode ^
        sampleInbound.hashCode ^
        agentAddCategoriyModel.hashCode;
  }
}
