import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:receipt_split/models/user.dart';

class UserService {
  UserService._privateConstructor();

  static final UserService _instance = UserService._privateConstructor();

  factory UserService() {
    return _instance;
  }

  final String _apiUrl = dotenv.env["API_URL"]!;

  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/users/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((userJson) => User.fromJson(userJson)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<User> createUser(String name, Color colour) async {
    try {
      String colourHex =
          colour.value.toRadixString(16).padLeft(8, '0').substring(2, 8);
      Map<String, dynamic> request = {"name": name, "colour": colourHex};

      final response = await http.post(Uri.parse('$_apiUrl/users/'),
          headers: {
            "Content-Type": "application/json", // Ensure JSON header
          },
          body: jsonEncode(request));

      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        User user = User.fromJson(data);

        return user;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User> updateUser(String id, String name, Color colour) async {
    try {
      String colourHex = colour.value.toRadixString(16).padLeft(8, '0');
      Map<String, dynamic> request = {"name": name, "colour": colourHex};

      final response = await http.put(Uri.parse('$_apiUrl/users/$id'),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(request));
      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        User user = User.fromJson(data);
        return user;
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteUserById(String id) async {
    Map<String, dynamic> request = {id: id};
    await http.delete(Uri.parse('$_apiUrl/users/$id'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(request));
  }

  void showUserOptionsDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          children: [
            GestureDetector(
              child: Text("Edit name"),
              onTap: () {},
            ),
            GestureDetector(
              child: Text("Delete this User"),
              onTap: () async {
                await _instance.deleteUserById(userId);
                // TODO: need to update state...

                // await PreferenceService().deleteUserById(userId);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
