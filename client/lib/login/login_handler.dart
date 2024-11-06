import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';

class LoginHandler {
  final CloudStorageManager _cloudStorageManager;

  LoginHandler(this._cloudStorageManager);

  Future<int> login(String email, String password) async {
    final id = await _cloudStorageManager.login(email, password);
    if (id == -1) {
      return -1;
    }

    print('Login successful');

    if (await LocalStorageManager.isAccountCashed(email)) {
      await LocalStorageManager.setMostRecentLogin(id);
      return id;
    } else {
      final row = {
        'id': id,
        'username': 'username',
        'email': email,
        'password': password,
        'most_recent_login': 1,
      };
      await LocalStorageManager.createAccount(row);
    }

    return id;
  }

  Future<int> register(String email, String username, String password) async {
    final isEmailRegistered =
        await _cloudStorageManager.isEmailRegistered(email);
    if (isEmailRegistered) {
      return -1;
    }

    final id =
        await _cloudStorageManager.createAccount(password, username, email);
    if (id == -1) {
      return -1;
    }

    final row = {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'most_recent_login': 1,
    };
    await LocalStorageManager.createAccount(row);

    return id;
  }
}
