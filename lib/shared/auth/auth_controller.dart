import 'package:shared_preferences/shared_preferences.dart';
import 'package:payflow/shared/models/user_model.dart';
import 'package:flutter/material.dart';

class AuthController {
  UserModel? _user;

  UserModel get user => _user!;

  void setUser(BuildContext context, UserModel? user) {
    if (user != null) {
      _user = user;
      saveUser(user);

      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      final sharedPreferencesInstance = await SharedPreferences.getInstance();

      await sharedPreferencesInstance.setString("user", user.toJson());

      return;
    } catch (error) {
      print(error);
    }
  }

  Future<void> currentUser(BuildContext context) async {
    try {
      await Future.delayed(Duration(seconds: 2));

      final sharedPreferencesInstance = await SharedPreferences.getInstance();

      if (sharedPreferencesInstance.containsKey('user')) {
        final user = sharedPreferencesInstance.get("user") as String;

        setUser(context, UserModel.fromJson(user));

        return;
      } else {
        setUser(context, null);
      }
    } catch (error) {
      print(error);
    }
  }
}
