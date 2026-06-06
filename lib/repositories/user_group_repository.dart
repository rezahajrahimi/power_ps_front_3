import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/user_group_model.dart';
import 'package:powerps/models/user_model.dart';

Future<Map<String, dynamic>?> getUserGroups({String? roleType}) async {
  try {
    final query = roleType != null ? {'role_type': roleType} : null;
    final response = await GenaralApi.dio.get(
      '/api/getUserGroups',
      queryParameters: query,
    );

    if (response.statusCode == 200 && response.data != null) {
      final groups = (response.data['groups'] as List)
          .map((e) => UserGroup.fromJson(e))
          .toList();
      final paymentKeyLabels =
          Map<String, String>.from(response.data['payment_keys'] ?? {});
      final verificationStats = response.data['verification_stats'] != null
          ? Map<String, int>.from({
              'verified': response.data['verification_stats']['verified'] ?? 0,
              'unverified': response.data['verification_stats']['unverified'] ?? 0,
              'without_group': response.data['verification_stats']['without_group'] ?? 0,
            })
          : null;
      final globalPayments = response.data['global_verification_payments'] != null
          ? (response.data['global_verification_payments'] as List)
              .map((e) => GlobalVerificationPaymentMethod.fromJson(e))
              .toList()
          : <GlobalVerificationPaymentMethod>[];
      return {
        'groups': groups,
        'paymentKeyLabels': paymentKeyLabels,
        'verificationStats': verificationStats,
        'globalVerificationPayments': globalPayments,
      };
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<UserGroup?> createUserGroup({
  required String name,
  required String roleType,
}) async {
  try {
    final response = await GenaralApi.dio.post('/api/createUserGroup', data: {
      'name': name,
      'role_type': roleType,
    });

    if (response.statusCode == 201 && response.data?['group'] != null) {
      return UserGroup.fromJson(response.data['group']);
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<bool> updateUserGroup({
  required int id,
  required String name,
}) async {
  try {
    final response = await GenaralApi.dio.put('/api/updateUserGroup/$id', data: {
      'name': name,
    });
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<bool> deleteUserGroup({required int id}) async {
  try {
    final response = await GenaralApi.dio.delete('/api/deleteUserGroup/$id');
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.response?.data?.toString() ?? e.message.toString());
    return false;
  }
}

Future<bool> updateGlobalVerificationPaymentMethods({
  required bool isVerified,
  required List<Map<String, dynamic>> paymentMethods,
}) async {
  try {
    final response = await GenaralApi.dio.put(
      '/api/updateGlobalVerificationPaymentMethods',
      data: {
        'is_verified': isVerified,
        'payment_methods': paymentMethods,
      },
    );
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<bool> updateUserGroupVerificationPaymentMethods({
  required int groupId,
  required bool isVerified,
  required List<Map<String, dynamic>> paymentMethods,
}) async {
  try {
    final response = await GenaralApi.dio.put(
      '/api/updateUserGroupVerificationPaymentMethods/$groupId',
      data: {
        'is_verified': isVerified,
        'payment_methods': paymentMethods,
      },
    );
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<bool> clearUserGroupVerificationPaymentMethods({
  required int groupId,
  required bool isVerified,
}) async {
  try {
    final response = await GenaralApi.dio.delete(
      '/api/clearUserGroupVerificationPaymentMethods/$groupId',
      data: {'is_verified': isVerified},
    );
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<bool> updateUserGroupPaymentMethods({
  required int groupId,
  required List<Map<String, dynamic>> paymentMethods,
}) async {
  try {
    final response = await GenaralApi.dio.put(
      '/api/updateUserGroupPaymentMethods/$groupId',
      data: {'payment_methods': paymentMethods},
    );
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<User?> assignUserToGroup({
  required int userId,
  int? userGroupId,
}) async {
  try {
    final response = await GenaralApi.dio.patch('/api/assignUserToGroup', data: {
      'user_id': userId,
      'user_group_id': userGroupId,
    });

    if (response.statusCode == 200 && response.data?['user'] != null) {
      return User.fromJson(response.data['user']);
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<List<User>?> getGroupUsers({required int groupId}) async {
  try {
    final response = await GenaralApi.dio.get('/api/getGroupUsers/$groupId');
    if (response.statusCode == 200 && response.data?['users'] != null) {
      return (response.data['users'] as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<List<User>?> addUsersToGroup({
  required int groupId,
  required List<int> userIds,
}) async {
  try {
    final response = await GenaralApi.dio.post('/api/addUsersToGroup', data: {
      'user_group_id': groupId,
      'user_ids': userIds,
    });
    if (response.statusCode == 200 && response.data?['users'] != null) {
      return (response.data['users'] as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<User?> removeUserFromGroup({required int userId}) async {
  try {
    final response = await GenaralApi.dio.patch('/api/removeUserFromGroup', data: {
      'user_id': userId,
    });
    if (response.statusCode == 200 && response.data?['user'] != null) {
      return User.fromJson(response.data['user']);
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<List<User>?> getNormalUsersForGrouping({
  String roleType = 'user',
  String? verificationFilter,
  int? userGroupId,
  int? excludeGroupId,
  String? search,
}) async {
  try {
    final response = await GenaralApi.dio.get(
      '/api/getNormalUsersForGrouping',
      queryParameters: {
        'role_type': roleType,
        if (verificationFilter != null) 'verification_filter': verificationFilter,
        if (userGroupId != null) 'user_group_id': userGroupId,
        if (excludeGroupId != null) 'exclude_group_id': excludeGroupId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.statusCode == 200 && response.data?['users'] != null) {
      return (response.data['users'] as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<User?> updateUserVerificationStatus({
  required int userId,
  required bool isVerified,
}) async {
  try {
    final response = await GenaralApi.dio.patch('/api/updateUserVerificationStatus', data: {
      'user_id': userId,
      'is_verified': isVerified,
    });

    if (response.statusCode == 200 && response.data?['user'] != null) {
      return User.fromJson(response.data['user']);
    }
    return null;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<bool> seedDefaultUserGroups() async {
  try {
    final response = await GenaralApi.dio.get('/api/seedDefaultUserGroups');
    return response.statusCode == 200;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}
