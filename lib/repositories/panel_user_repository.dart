import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/auth_provider.dart';

Future<dynamic> getUserInfo() async {
  try {
    Response response = await GenaralApi.dio.get("/api/user");

    if (response.statusCode == 200 && response.data != null) {
      User user = User.fromJson(response.data);
      return user;
    } else if (response.statusCode == 201) {
      return null;
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<bool> updateUser({required User user, required String password}) async {
  try {
    Response response = await GenaralApi.dio.put("/api/updateUser", data: {
      "name": user.name,
      "password": password,
      "account_id": user.accountId,
      "id": user.id,
      "role": user.role
    });

    if (response.statusCode == 200 && response.data != null && response.data['user'] != null) {
      User user = User.fromJson(response.data["user"]);
      AuthChangeController().setUser(user);
      return true;
    } else if (response.statusCode == 201) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<bool> updateUserPassword({required String password}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/updateUserPassword", data: {
      "password": password,
    });

    if (response.statusCode == 200 && response.data != null) {
      return true;
    } else if (response.statusCode == 200) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future getAgents() async {
  try {
    List<User> userList = [];

    await GenaralApi.dio.get("/api/getAgents").then((response) {
      if (response.statusCode == 200 && response.data != null) {
        for (var i in response.data['agents']) {
          User user = User.fromJson(i);
          userList.add(user);
        }
        return userList;
      } else if (response.statusCode == 201) {
        return null;
      } else if (response.statusCode == 401) {
        return null;
      } else if (response.statusCode == 500) {
        return null;
      } else {
        return null;
      }
    }).catchError((e) {
      debugPrint(e.toString());
      return null;
    });
    return userList;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<List<User>?> getAdmins() async {
  try {
    List<User> userList = [];

    await GenaralApi.dio.get("/api/getAdminUsers").then((response) {
      if (response.statusCode == 200 && response.data != null) {
        for (var i in response.data['admins']) {
          User user = User.fromJson(i);
          userList.add(user);
        }
        return userList;
      } else if (response.statusCode == 201) {
        return null;
      } else if (response.statusCode == 401) {
        return null;
      } else if (response.statusCode == 500) {
        return null;
      } else {
        return null;
      }
    }).catchError((e) {
      debugPrint(e.toString());
      return null;
    });
    return userList;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

Future<bool> changeUserRoleToAdmin({required int userId}) async {
  try {
    Response response =
        await GenaralApi.dio.patch("/api/changeUserRoleToAdmin/$userId");

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<bool> changeAgentRoleToUser({required int userId}) async {
  try {
    Response response =
        await GenaralApi.dio.patch("/api/changeAgentRoleToUser/$userId");

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}

Future<List<User>?> getNormalUsers() async {
  try {
    List<User> userList = [];

    await GenaralApi.dio.get("/api/getNormalUsers").then((response) {
      if (response.statusCode == 200 && response.data != null) {
        for (var i in response.data['users']) {
          User user = User.fromJson(i);
          userList.add(user);
        }
        return userList;
      } else if (response.statusCode == 201) {
        return null;
      } else if (response.statusCode == 401) {
        return null;
      } else if (response.statusCode == 500) {
        return null;
      } else {
        return null;
      }
    }).catchError((e) {
      debugPrint(e.toString());
      return null;
    });
    return userList;
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return null;
  }
}

changeAgentPassword({required String password}) async {
  try {
    Response response =
        await GenaralApi.dio.put("/api/updateAgentPassword", data: {
      "password": password,
    });

    if (response.statusCode == 200 && response.data != null) {
      return true;
    } else if (response.statusCode == 201) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      return false;
    }
  } on DioException catch (e) {
    debugPrint(e.message.toString());
    return false;
  }
}
