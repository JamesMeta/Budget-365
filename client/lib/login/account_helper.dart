import 'package:supabase_flutter/supabase_flutter.dart';

class AccountHelper {
  final SupabaseClient _supabase;

  //constructor that takes the Supabase client as a parameter
  AccountHelper(this._supabase);

  //method to create a new account
  Future<void> createAccount(
      int id, String passwordHash, String accountName, String email) async {
    try {
      await _supabase.from('account').insert({
        'id': id,
        'password_hash': passwordHash,
        'account_name': accountName,
        'email': email,
      });
      print('Account created successfully');
    } catch (error) {
      print('Error creating account: $error');
    }
  }

  //method to get a report of all accounts
  Future<List<Map<String, dynamic>>> getAccountReport() async {
    try {
      final response = await _supabase.from('account').select();

      if (response == null || response.isEmpty) {
        print('No accounts found.');
        return [];
      }

      return response as List<Map<String, dynamic>>;
    } catch (error) {
      print('Error fetching account report: $error');
      return [];
    }
  }
}
