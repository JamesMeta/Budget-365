import 'dart:math';

import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';

class LoginHandler {
  final CloudStorageManager _cloudStorageManager;

  LoginHandler(this._cloudStorageManager);

  Future<String?> login(String email, String password) async {
    final id = await _cloudStorageManager.login(email, password);
    if (int.tryParse(id!) == null) {
      return id;
    }

    if (await LocalStorageManager.isAccountCashed(email)) {
      await LocalStorageManager.setMostRecentLogin(int.parse(id));
      return id;
    } else {
      final row = {
        'id': int.parse(id),
        'username': 'username',
        'email': email,
        'password': password,
        'most_recent_login': 1,
      };
      await LocalStorageManager.createAccount(row);
    }

    return id;
  }

  Future<String?> register(
      String email, String username, String password) async {
    email = email.toLowerCase().trim();
    username = username.trim();
    final isEmailRegistered =
        await _cloudStorageManager.isEmailRegistered(email);
    if (isEmailRegistered) {
      return 'Email already registered to an account';
    }

    final response =
        await _cloudStorageManager.createAccount(password, username, email);

    //if response is not string number, then it is an error message
    if (int.tryParse(response!) == null) {
      return response;
    }

    int id = int.parse(response);

    final row = {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'most_recent_login': 1,
    };
    await LocalStorageManager.createAccount(row);

    return response;
  }
}
