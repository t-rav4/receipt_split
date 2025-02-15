import 'dart:convert';

import 'package:receipt_split/types/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  PreferenceService._privateConstructor();

  static const String userKey = "saved_users";

  static final PreferenceService _instance =
      PreferenceService._privateConstructor();

  factory PreferenceService() {
    return _instance;
  }

  Future<List<User>> fetchSavedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJSON = prefs.getString(userKey);
    if (usersJSON != null) {
      final List<dynamic> decodedList = jsonDecode(usersJSON);
      print("ok");
      print(decodedList);
      return decodedList.map((json) => User.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(users.map((user) => user.toJSON()).toList());

    await prefs.setString(userKey, jsonString);
  }

  Future<void> deleteUserById(String id) async {
    List<User> users = await fetchSavedUsers();

    users.removeWhere((u) => u.id == id);

    await saveUsers(users);
  }
}
