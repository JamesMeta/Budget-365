import 'package:budget_365/utility/local_storage_manager.dart';

class LoginHandler {
  // this function is currently implemented in a testing manner and is not ready for production
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final accounts = await LocalStorageManager.fetchAccounts();
    final loggedInAccount = accounts.firstWhere(
        (account) => account['username'] == username,
        orElse: () => {});

    if (loggedInAccount == {}) {
      return {
        'success': false,
        'message': 'Account not found',
      };
    } else if (loggedInAccount['password_hash'] != password) {
      return {
        'success': false,
        'message': 'Incorrect password',
      };
    } else {
      await LocalStorageManager.setMostRecentLogin(loggedInAccount['id']);

      return {
        'success': true,
        'account': loggedInAccount,
      };
    }
  }

  // this function is currently implemented in a testing manner and is not ready for production
  static Future<int> register(
      String email, String username, String password) async {
    final accounts = await LocalStorageManager.fetchAccounts();
    final existingAccount = accounts
        .firstWhere((account) => account['email'] == email, orElse: () => {});

    if (existingAccount.isNotEmpty) {
      return -1;
    } else {
      final account = {
        'username': username,
        'password_hash': password,
        'email': email,
        'account_code': email,
        'most_recent_login': 1,
      };

      int id = await LocalStorageManager.createAccount(account);
      await LocalStorageManager.setMostRecentLogin(id);
      return id;
    }
  }
}
