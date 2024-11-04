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
      // ignore: empty_catches
    } catch (error) {}
  }

  //method to get a report of all accounts
  Future<List<Map<String, dynamic>>> getAccountReport() async {
    try {
      final response = await _supabase.from('account').select();

      if (response.isEmpty) {
        return [];
      }

      return response;
    } catch (error) {
      return [];
    }
  }
}
