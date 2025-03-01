import 'package:dio/dio.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/bot_user_model.dart';

Future<List<BotUser>> getBlockedUsers() async {
  Response response = await GenaralApi.dio.get("/api/get-all-blocked-users");
  if (response.statusCode == 200 && response.data != null) {
    List<BotUser> blockedUsers = [];
    for (var i in response.data) {
      blockedUsers.add(BotUser.fromJson(i));
    }
    return blockedUsers;
  }
  return [];
}

Future<bool> blockUser(String accountId, String reason) async {
  Response response = await GenaralApi.dio.post("/api/add-blocked-user", data: {
    "accountId": accountId,
    "reason": reason,
  });
  if (response.statusCode == 200 && response.data != null) {
    return true;
  }
  return false;
}

Future<bool> unblockUser(String accountId) async {
  Response response = await GenaralApi.dio.post("/api/remove-blocked-user", data: {
    "accountId": accountId,
  });
  if (response.statusCode == 200 && response.data != null) {
    return true;
  }
  return false;
}

Future<BotUser> getBlockedUser(String accountId) async {
  Response response = await GenaralApi.dio.get("/api/get-blocked-user", data: {
    "accountId": accountId,
  });
  if (response.statusCode == 200 && response.data != null) {
    return BotUser.fromJson(response.data);
  }
  return BotUser(id: BigInt.zero, accountId: BigInt.zero, username: "", firstName: "", lastName: "", createdAt: "", updatedAt: "", ballance: null, referralWallet: null, transactions: [], products: [], blockedUser: null);
}

Future<bool> isBlocked(String accountId) async {
  Response response = await GenaralApi.dio.get("/api/is-blocked", data: {
    "accountId": accountId,
  });
  if (response.statusCode == 200 && response.data != null) {
    return response.data;
  }
  return false;
}

Future<int> getBlockedUserCount() async {
  Response response = await GenaralApi.dio.get("/api/get-blocked-user-count");
  if (response.statusCode == 200 && response.data != null) {
    return response.data;
  }
  return 0;
}
